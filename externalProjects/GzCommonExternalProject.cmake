#[[ Cmake guard. ]]
if(TARGET GzCommonExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SpdLogExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzCommonExternalProject "Forcefully skip gz-common" OFF)

if(ROBOT_FARM_SKIP_GzCommonExternalProject)
  add_custom_target(GzCommonExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzCommonExternalProject)

  set(ROBOT_FARM_GZ_COMMON_URL
    "https://github.com/gazebosim/gz-common/archive/refs/tags/gz-common7_7.3.1.tar.gz"
    CACHE STRING
    "URL of the gz-common source archive")

  externalproject_add(GzCommonExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-common
    URL ${ROBOT_FARM_GZ_COMMON_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzCommonExternalProject
  GzCmakeExternalProject
  GzMathExternalProject
  GzUtilsExternalProject
  SpdLogExternalProject)
