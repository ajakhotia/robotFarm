#[[ Cmake guard. ]]
if(TARGET CeresSolverExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GlogExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)

option(ROBOT_FARM_SKIP_CERES "Skip Ceres Solver" OFF)

if(ROBOT_FARM_SKIP_CERES)
    add_custom_target(CeresSolverExternalProject)
else()
    set(ROBOT_FARM_CERES_SOLVER_URL
        "https://github.com/ceres-solver/ceres-solver/archive/refs/tags/2.0.0.tar.gz"
        CACHE STRING
        "URL of the Ceres Solver source archive")

    externalproject_add(CeresSolverExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
        URL ${ROBOT_FARM_CERES_SOLVER_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(CeresSolverExternalProject
    GFlagsExternalProject
    GlogExternalProject
    Eigen3ExternalProject)
