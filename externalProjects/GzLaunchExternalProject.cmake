if(TARGET GzLaunchExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzGuiExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzSimExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzTransportExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzLaunchExternalProject "Forcefully skip gz-launch" OFF)

if(ROBOT_FARM_SKIP_GzLaunchExternalProject)
  add_custom_target(GzLaunchExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzLaunchExternalProject)

  set(ROBOT_FARM_GZ_LAUNCH_URL
    "https://github.com/gazebosim/gz-launch/archive/refs/tags/gz-launch9_9.0.1.tar.gz"
    CACHE STRING
    "URL of the gz-launch source archive")

  externalproject_add(GzLaunchExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-launch
    URL ${ROBOT_FARM_GZ_LAUNCH_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzLaunchExternalProject
  GFlagsExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzGuiExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzPluginExternalProject
  GzSimExternalProject
  GzToolsExternalProject
  GzTransportExternalProject)
