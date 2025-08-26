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
    function(make_space_delimited_string OUTPUT_VAR)
      string (REPLACE ";" " " SPACE_DELIMITED_STRING "${ARGN}")
      set(${OUTPUT_VAR} ${SPACE_DELIMITED_STRING} PARENT_SCOPE)
    endfunction()

    list(APPEND ROBOT_FARM_BUILD_LIST CeresSolverExternalProject)

    set(ROBOT_FARM_CERES_SOLVER_URL
        "https://github.com/ceres-solver/ceres-solver.git"
        CACHE STRING
        "URL of the Ceres Solver source archive")

    find_package(OpenMP REQUIRED)
    make_space_delimited_string(CERES_C_FLAGS ${OpenMP_C_FLAGS} ${CMAKE_C_FLAGS})
    make_space_delimited_string(CERES_CXX_FLAGS ${OpenMP_CXX_FLAGS} ${CMAKE_CXX_FLAGS})
    make_space_delimited_string(CERES_EXE_LINKER_FLAGS ${OMP_LINK_LIBS} ${CMAKE_EXE_LINKER_FLAGS})
    make_space_delimited_string(CERES_SHARED_LINKER_FLAGS ${OMP_LINK_LIBS} ${CMAKE_SHARED_LINKER_FLAGS} )

    externalproject_add(CeresSolverExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
        GIT_REPOSITORY ${ROBOT_FARM_CERES_SOLVER_URL}
        GIT_SHALLOW TRUE
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_CACHE_ARGS
          ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
          -DCMAKE_C_FLAGS:STRING=${CERES_C_FLAGS}
          -DCMAKE_CXX_FLAGS:STRING=${CERES_CXX_FLAGS}
          -DCMAKE_EXE_LINKER_FLAGS:STRING=${CERES_EXE_LINKER_FLAGS}
          -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CERES_SHARED_LINKER_FLAGS})
endif()

add_dependencies(CeresSolverExternalProject
    AbseilExternalProject
    Eigen3ExternalProject
    GFlagsExternalProject
    GlogExternalProject
    SuiteSparseExternalProject)
