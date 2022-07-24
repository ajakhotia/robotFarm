#[[ Cmake guard. ]]
if(TARGET GlogExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)

option(ROBOT_FARM_SKIP_GLOG "Skip Glog" OFF)

if(ROBOT_FARM_SKIP_GLOG)
    add_custom_target(GlogExternalProject)
else()
    set(ROBOT_FARM_GLOG_URL
        "https://github.com/google/glog/archive/refs/tags/v0.6.0.tar.gz"
        CACHE STRING
        "URL of the Google Log source archive")

    externalproject_add(GlogExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/glog
        URL ${ROBOT_FARM_GLOG_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GlogExternalProject
    GFlagsExternalProject
    GoogleTestExternalProject)
