#[[ CMake guard. ]]
if(TARGET BoostExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/Python3ExternalProject.cmake)

option(ROBOT_FARM_SKIP_BoostExternalProject "Forcefully skip Boost" OFF)

if(ROBOT_FARM_SKIP_BoostExternalProject)
  add_custom_target(BoostExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST BoostExternalProject)

  set(ROBOT_FARM_BOOST_URL
    "https://github.com/boostorg/boost/releases/download/boost-1.91.0-1/boost-1.91.0-1-cmake.tar.gz"
    CACHE STRING "URL of the Boost source archive")

  externalproject_add(BoostExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/boost
    URL ${ROBOT_FARM_BOOST_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(BoostExternalProject Python3ExternalProject)
