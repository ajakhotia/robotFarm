#[[ Cmake guard. ]]
if(TARGET GzSensorsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzRenderingExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzTransportExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SdformatExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzSensorsExternalProject "Forcefully skip gz-sensors" OFF)

if(ROBOT_FARM_SKIP_GzSensorsExternalProject)
  add_custom_target(GzSensorsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzSensorsExternalProject)

  set(ROBOT_FARM_GZ_SENSORS_URL
    "https://github.com/gazebosim/gz-sensors/archive/refs/tags/gz-sensors10_10.0.2.tar.gz"
    CACHE STRING
    "URL of the gz-sensors source archive")

  externalproject_add(GzSensorsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-sensors
    URL ${ROBOT_FARM_GZ_SENSORS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzSensorsExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzRenderingExternalProject
  GzToolsExternalProject
  GzTransportExternalProject
  SdformatExternalProject)
