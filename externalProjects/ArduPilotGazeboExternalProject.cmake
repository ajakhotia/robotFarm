if(TARGET ArduPilotGazeboExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzRenderingExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzSimExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/OpenCVExternalProject.cmake)

option(ROBOT_FARM_SKIP_ArduPilotGazeboExternalProject "Forcefully skip the ArduPilot Gazebo plugin" OFF)

if(ROBOT_FARM_SKIP_ArduPilotGazeboExternalProject)
  add_custom_target(ArduPilotGazeboExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST ArduPilotGazeboExternalProject)

  #[[ Upstream publishes no releases or tags, only branches; this pins the head of main that
      carries Gazebo Jetty support. Move to a tagged archive once upstream starts tagging. ]]
  set(ROBOT_FARM_ARDUPILOT_GAZEBO_URL
    "https://github.com/ArduPilot/ardupilot_gazebo/archive/f116b03552d05c8d0b0bed5ed67033a1183121d1.tar.gz"
    CACHE STRING
    "URL of the ArduPilot Gazebo plugin source archive")

  # Upstream selects the Gazebo release from the GZ_VERSION environment variable rather than
  # a cache entry, so the configure step runs under it.
  externalproject_add(ArduPilotGazeboExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ardupilot-gazebo
    URL ${ROBOT_FARM_ARDUPILOT_GAZEBO_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_COMMAND ${CMAKE_COMMAND} -E env GZ_VERSION=jetty ${CMAKE_COMMAND}
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(ArduPilotGazeboExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzRenderingExternalProject
  GzSimExternalProject
  OpenCVExternalProject)
