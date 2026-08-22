if(TARGET GzPluginExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzPluginExternalProject "Forcefully skip gz-plugin" OFF)

if(ROBOT_FARM_SKIP_GzPluginExternalProject)
  add_custom_target(GzPluginExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzPluginExternalProject)

  set(ROBOT_FARM_GZ_PLUGIN_URL
    "https://github.com/gazebosim/gz-plugin/archive/refs/tags/gz-plugin4_4.0.0.tar.gz"
    CACHE STRING
    "URL of the gz-plugin source archive")

  externalproject_add(GzPluginExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-plugin
    URL ${ROBOT_FARM_GZ_PLUGIN_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzPluginExternalProject
  GzCmakeExternalProject
  GzToolsExternalProject
  GzUtilsExternalProject)
