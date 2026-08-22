if(TARGET GzCmakeExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_GzCmakeExternalProject "Forcefully skip gz-cmake" OFF)

if(ROBOT_FARM_SKIP_GzCmakeExternalProject)
  add_custom_target(GzCmakeExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzCmakeExternalProject)

  set(ROBOT_FARM_GZ_CMAKE_URL
    "https://github.com/gazebosim/gz-cmake/archive/refs/tags/gz-cmake5_5.1.1.tar.gz"
    CACHE STRING
    "URL of the gz-cmake source archive")

  externalproject_add(GzCmakeExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-cmake
    URL ${ROBOT_FARM_GZ_CMAKE_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()
