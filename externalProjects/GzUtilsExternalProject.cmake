if(TARGET GzUtilsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SpdLogExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzUtilsExternalProject "Forcefully skip gz-utils" OFF)

if(ROBOT_FARM_SKIP_GzUtilsExternalProject)
  add_custom_target(GzUtilsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzUtilsExternalProject)

  set(ROBOT_FARM_GZ_UTILS_URL
    "https://github.com/gazebosim/gz-utils/archive/refs/tags/gz-utils4_4.0.0.tar.gz"
    CACHE STRING
    "URL of the gz-utils source archive")

  externalproject_add(GzUtilsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-utils
    URL ${ROBOT_FARM_GZ_UTILS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzUtilsExternalProject
  GzCmakeExternalProject
  SpdLogExternalProject)
