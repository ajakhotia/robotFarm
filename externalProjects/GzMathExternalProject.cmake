#[[ Cmake guard. ]]
if(TARGET GzMathExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzMathExternalProject "Forcefully skip gz-math" OFF)

if(ROBOT_FARM_SKIP_GzMathExternalProject)
  add_custom_target(GzMathExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzMathExternalProject)

  set(ROBOT_FARM_GZ_MATH_URL
    "https://github.com/gazebosim/gz-math/archive/refs/tags/gz-math9_9.2.0.tar.gz"
    CACHE STRING
    "URL of the gz-math source archive")

  externalproject_add(GzMathExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-math
    URL ${ROBOT_FARM_GZ_MATH_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzMathExternalProject
  Eigen3ExternalProject
  GzCmakeExternalProject
  GzUtilsExternalProject)
