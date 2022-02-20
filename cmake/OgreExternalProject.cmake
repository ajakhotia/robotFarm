#[[ CMake guard. ]]
if(TARGET OgreExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/BoostExternalProject.cmake)

option(ROBOT_FARM_SKIP_OGRE "Skip Ogre" OFF)

if(ROBOT_FARM_SKIP_OGRE)
    add_custom_target(OgreExternalProject)
else()
    set(ROBOT_FARM_OGRE_URL
        "https://github.com/OGRECave/ogre/archive/refs/tags/v13.2.4.tar.gz"
        CACHE STRING
        "URL of the OGRE source archive")

    externalproject_add(OgreExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ogre
        URL ${ROBOT_FARM_OGRE_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
            ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
            -DOGRE_BUILD_COMPONENT_OVERLAY_IMGUI:BOOL=OFF
            -DOGRE_BUILD_DEPENDENCIES:BOOL=OFF)
endif()

add_dependencies(OgreExternalProject
    BoostExternalProject)
