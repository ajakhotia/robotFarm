if(TARGET CeresSolverExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/AbseilExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CudssExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GlogExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SuiteSparseExternalProject.cmake)

option(ROBOT_FARM_SKIP_CeresSolverExternalProject "Forcefully skip Ceres Solver" OFF)

if(ROBOT_FARM_SKIP_CeresSolverExternalProject)
  add_custom_target(CeresSolverExternalProject)
else()
  function(make_space_delimited_string OUTPUT_VAR)
    string(REPLACE ";" " " SPACE_DELIMITED_STRING "${ARGN}")
    set(${OUTPUT_VAR} ${SPACE_DELIMITED_STRING} PARENT_SCOPE)
  endfunction()

  list(APPEND ROBOT_FARM_BUILD_LIST CeresSolverExternalProject)

  set(ROBOT_FARM_CERES_SOLVER_URL
    "https://github.com/ceres-solver/ceres-solver.git"
    CACHE STRING
    "URL of the Ceres Solver source archive")

  find_package(OpenMP REQUIRED)

  #[[ SuiteSparse built with CUDA hardcodes CHOLMOD_HAS_CUDA into the installed cholmod.h,
      so every compile that includes it needs the CUDA headers. Ceres finds SuiteSparse
      through its own module-mode finder, whose cholmod_metis probe (the Partition
      component gate) knows nothing of that coupling; feed the CUDA include directories
      through the compiler flags so the probe and the library build both see them. ]]
  find_package(CUDAToolkit)
  set(CERES_CUDA_INCLUDE_FLAGS "")
  if(CUDAToolkit_FOUND)
    foreach(CERES_CUDA_INCLUDE_DIR ${CUDAToolkit_INCLUDE_DIRS})
      string(APPEND CERES_CUDA_INCLUDE_FLAGS " -isystem ${CERES_CUDA_INCLUDE_DIR}")
    endforeach()
  endif()

  make_space_delimited_string(CERES_C_FLAGS ${OpenMP_C_FLAGS} ${CMAKE_C_FLAGS} ${CERES_CUDA_INCLUDE_FLAGS})
  make_space_delimited_string(CERES_CXX_FLAGS ${OpenMP_CXX_FLAGS} ${CMAKE_CXX_FLAGS} ${CERES_CUDA_INCLUDE_FLAGS})
  make_space_delimited_string(CERES_EXE_LINKER_FLAGS ${OMP_LINK_LIBS} ${CMAKE_EXE_LINKER_FLAGS})
  make_space_delimited_string(CERES_SHARED_LINKER_FLAGS ${OMP_LINK_LIBS} ${CMAKE_SHARED_LINKER_FLAGS})

  #[[ Two upstream defects, both proposed upstream; drop the patch once a release carries
      them. Ceres overwrites CMAKE_CUDA_ARCHITECTURES with its own generation table after
      enabling CUDA, discarding the toolchain's value; the patch makes the table the default
      only when none was supplied and moves it before enable_language. And its static
      companion library reflects the shared target's interface through a TARGET_PROPERTY
      generator expression, which newer CMake rejects as transitively recursive; the patch
      spells out the direct dependency list. ]]
  externalproject_add(CeresSolverExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
    GIT_REPOSITORY ${ROBOT_FARM_CERES_SOLVER_URL}
    GIT_SHALLOW TRUE
    GIT_SUBMODULES ""
    PATCH_COMMAND patch -p1 -i ${CMAKE_SOURCE_DIR}/patches/ceresSolver.patch
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_CACHE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    # Upstream defaults WITH_SUITESPARSE to OFF; without it Ceres silently drops the
    # CHOLMOD/SPQR sparse solvers, CHOLMOD partitioning and single-precision factorization.
    -DWITH_SUITESPARSE:BOOL=ON
    -DCMAKE_C_FLAGS:STRING=${CERES_C_FLAGS}
    -DCMAKE_CXX_FLAGS:STRING=${CERES_CXX_FLAGS}
    -DCMAKE_EXE_LINKER_FLAGS:STRING=${CERES_EXE_LINKER_FLAGS}
    -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CERES_SHARED_LINKER_FLAGS})
endif()

add_dependencies(CeresSolverExternalProject
  AbseilExternalProject
  CudssExternalProject
  Eigen3ExternalProject
  GFlagsExternalProject
  GlogExternalProject
  SuiteSparseExternalProject)
