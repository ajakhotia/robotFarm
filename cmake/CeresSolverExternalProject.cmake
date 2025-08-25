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

    externalproject_add(CeresSolverExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
        GIT_REPOSITORY ${ROBOT_FARM_CERES_SOLVER_URL}
        GIT_SHALLOW TRUE
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(CeresSolverExternalProject
    AbseilExternalProject
    Eigen3ExternalProject
    GFlagsExternalProject
    GlogExternalProject
    SuiteSparseExternalProject)
