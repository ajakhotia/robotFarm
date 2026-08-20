#[[ Cmake guard. ]]
if(TARGET GzFuelToolsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzFuelToolsExternalProject "Forcefully skip gz-fuel-tools" OFF)

if(ROBOT_FARM_SKIP_GzFuelToolsExternalProject)
  add_custom_target(GzFuelToolsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzFuelToolsExternalProject)

  set(ROBOT_FARM_GZ_FUEL_TOOLS_URL
    "https://github.com/gazebosim/gz-fuel-tools/archive/refs/tags/gz-fuel-tools11_11.0.0.tar.gz"
    CACHE STRING
    "URL of the gz-fuel-tools source archive")

  externalproject_add(GzFuelToolsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-fuel-tools
    URL ${ROBOT_FARM_GZ_FUEL_TOOLS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzFuelToolsExternalProject
  GFlagsExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzToolsExternalProject
  GzUtilsExternalProject)
