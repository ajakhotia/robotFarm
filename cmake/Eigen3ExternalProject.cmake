#[[ Cmake guard. ]]
if(TARGET Eigen3ExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/BoostExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SuiteSparseExternalProject.cmake)

option(ROBOT_FARM_SKIP_Eigen3ExternalProject "Forcefully skip Eigen3" OFF)

if(ROBOT_FARM_SKIP_Eigen3ExternalProject)
    add_custom_target(Eigen3ExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST Eigen3ExternalProject)

    set(ROBOT_FARM_EIGEN3_URL
        "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz"
        CACHE STRING
        "URL of the Eigen3 source archive")

    externalproject_add(Eigen3ExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/eigen3
        URL ${ROBOT_FARM_EIGEN3_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(Eigen3ExternalProject
    BoostExternalProject
    SuiteSparseExternalProject)
