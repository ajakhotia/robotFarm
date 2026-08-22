if(TARGET GzTransportExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtobufExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ZenohCExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ZenohCppExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzTransportExternalProject "Forcefully skip gz-transport" OFF)

if(ROBOT_FARM_SKIP_GzTransportExternalProject)
  add_custom_target(GzTransportExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzTransportExternalProject)

  set(ROBOT_FARM_GZ_TRANSPORT_URL
    "https://github.com/gazebosim/gz-transport/archive/refs/tags/gz-transport15_15.1.0.tar.gz"
    CACHE STRING
    "URL of the gz-transport source archive")

  externalproject_add(GzTransportExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-transport
    URL ${ROBOT_FARM_GZ_TRANSPORT_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DGZ_TRANSPORT_ENABLE_ZENOH:BOOL=ON)
endif()

add_dependencies(GzTransportExternalProject
  GzCmakeExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzToolsExternalProject
  GzUtilsExternalProject
  ProtobufExternalProject
  ZenohCExternalProject
  ZenohCppExternalProject)
