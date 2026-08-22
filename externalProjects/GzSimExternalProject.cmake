if(TARGET GzSimExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzFuelToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzGuiExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPhysicsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzRenderingExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzSensorsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzTransportExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtobufExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SdformatExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzSimExternalProject "Forcefully skip gz-sim" OFF)

if(ROBOT_FARM_SKIP_GzSimExternalProject)
  add_custom_target(GzSimExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzSimExternalProject)

  set(ROBOT_FARM_GZ_SIM_URL
    "https://github.com/gazebosim/gz-sim/archive/refs/tags/gz-sim10_10.5.0.tar.gz"
    CACHE STRING
    "URL of the gz-sim source archive")

  externalproject_add(GzSimExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-sim
    URL ${ROBOT_FARM_GZ_SIM_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzSimExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzFuelToolsExternalProject
  GzGuiExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzPhysicsExternalProject
  GzPluginExternalProject
  GzRenderingExternalProject
  GzSensorsExternalProject
  GzToolsExternalProject
  GzTransportExternalProject
  GzUtilsExternalProject
  ProtobufExternalProject
  SdformatExternalProject)
