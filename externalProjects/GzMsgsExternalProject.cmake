#[[ Cmake guard. ]]
if(TARGET GzMsgsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtobufExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzMsgsExternalProject "Forcefully skip gz-msgs" OFF)

if(ROBOT_FARM_SKIP_GzMsgsExternalProject)
  add_custom_target(GzMsgsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzMsgsExternalProject)

  set(ROBOT_FARM_GZ_MSGS_URL
    "https://github.com/gazebosim/gz-msgs/archive/refs/tags/gz-msgs12_12.0.2.tar.gz"
    CACHE STRING
    "URL of the gz-msgs source archive")

  externalproject_add(GzMsgsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-msgs
    URL ${ROBOT_FARM_GZ_MSGS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzMsgsExternalProject
  GzCmakeExternalProject
  GzMathExternalProject
  GzToolsExternalProject
  ProtobufExternalProject)
