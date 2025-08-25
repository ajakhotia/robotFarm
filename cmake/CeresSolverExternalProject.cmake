#[[ Cmake guard. ]]
if(TARGET CeresSolverExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/AbseilExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GlogExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SuiteSparseExternalProject.cmake)

option(ROBOT_FARM_SKIP_CeresSolverExternalProject "Forcefully skip Ceres Solver" OFF)

if(ROBOT_FARM_SKIP_CeresSolverExternalProject)
    add_custom_target(CeresSolverExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST CeresSolverExternalProject)

    set(ROBOT_FARM_CERES_SOLVER_URL
        "https://github.com/ceres-solver/ceres-solver.git"
        CACHE STRING
        "URL of the Ceres Solver source archive")

    find_package(OpenMP REQUIRED)
    set(OMP_C_FLAGS        "${OpenMP_C_FLAGS}")
    set(OMP_CXX_FLAGS      "${OpenMP_CXX_FLAGS}")
    set(OMP_LINK_LIBS      "${OpenMP_CXX_LIBRARIES}")

    set(CERES_C_FLAGS        "${CMAKE_C_FLAGS} ${OMP_C_FLAGS}")
    set(CERES_CXX_FLAGS      "${CMAKE_CXX_FLAGS} ${OMP_CXX_FLAGS}")
    set(CERES_EXE_LDFLAGS    "${CMAKE_EXE_LINKER_FLAGS} ${OMP_LINK_LIBS}")
    set(CERES_SHARED_LDFLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OMP_LINK_LIBS}")

    externalproject_add(CeresSolverExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
        GIT_REPOSITORY ${ROBOT_FARM_CERES_SOLVER_URL}
        GIT_SHALLOW TRUE
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_CACHE_ARGS
          ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
          -DCMAKE_C_FLAGS:STRING=${CERES_C_FLAGS}
          -DCMAKE_CXX_FLAGS:STRING=${CERES_CXX_FLAGS}
          -DCMAKE_EXE_LINKER_FLAGS:STRING=${CERES_EXE_LDFLAGS}
          -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CERES_SHARED_LDFLAGS})
endif()

add_dependencies(CeresSolverExternalProject
    AbseilExternalProject
    Eigen3ExternalProject
    GFlagsExternalProject
    GlogExternalProject
    SuiteSparseExternalProject)
