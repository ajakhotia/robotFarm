if(TARGET GzToolsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzToolsExternalProject "Forcefully skip gz-tools" OFF)

if(ROBOT_FARM_SKIP_GzToolsExternalProject)
  add_custom_target(GzToolsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzToolsExternalProject)

  set(ROBOT_FARM_GZ_TOOLS_URL
    "https://github.com/gazebosim/gz-tools/archive/refs/tags/gz-tools2_2.0.4.tar.gz"
    CACHE STRING
    "URL of the gz-tools source archive")

  externalproject_add(GzToolsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-tools
    URL ${ROBOT_FARM_GZ_TOOLS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzToolsExternalProject
  GzCmakeExternalProject)
