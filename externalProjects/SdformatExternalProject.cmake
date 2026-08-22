if(TARGET SdformatExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)

option(ROBOT_FARM_SKIP_SdformatExternalProject "Forcefully skip sdformat" OFF)

if(ROBOT_FARM_SKIP_SdformatExternalProject)
  add_custom_target(SdformatExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST SdformatExternalProject)

  set(ROBOT_FARM_SDFORMAT_URL
    "https://github.com/gazebosim/sdformat/archive/refs/tags/sdformat16_16.1.0.tar.gz"
    CACHE STRING
    "URL of the sdformat source archive")

  externalproject_add(SdformatExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/sdformat
    URL ${ROBOT_FARM_SDFORMAT_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(SdformatExternalProject
  GzCmakeExternalProject
  GzMathExternalProject
  GzToolsExternalProject
  GzUtilsExternalProject)
