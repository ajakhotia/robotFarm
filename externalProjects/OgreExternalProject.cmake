if(TARGET OgreExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/BoostExternalProject.cmake)

option(ROBOT_FARM_SKIP_OgreExternalProject "Forcefully skip Ogre" OFF)

if(ROBOT_FARM_SKIP_OgreExternalProject)
  add_custom_target(OgreExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST OgreExternalProject)

  set(ROBOT_FARM_OGRE_URL
    "https://github.com/OGRECave/ogre/archive/refs/tags/v14.5.2.tar.gz"
    CACHE STRING
    "URL of the OGRE source archive")

  externalproject_add(OgreExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ogre
    URL ${ROBOT_FARM_OGRE_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DOGRE_BUILD_COMPONENT_OVERLAY_IMGUI:BOOL=OFF
    -DOGRE_BUILD_COMPONENT_PYTHON:BOOL=ON
    -DOGRE_BUILD_DEPENDENCIES:BOOL=OFF
    -DOGRE_BUILD_PLUGIN_GLSLANG:BOOL=ON
    -DOGRE_BUILD_RENDERSYSTEM_VULKAN:BOOL=ON)
endif()

add_dependencies(OgreExternalProject
  BoostExternalProject)
