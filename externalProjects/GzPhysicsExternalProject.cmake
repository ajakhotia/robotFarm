if(TARGET GzPhysicsExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SdformatExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzPhysicsExternalProject "Forcefully skip gz-physics" OFF)

if(ROBOT_FARM_SKIP_GzPhysicsExternalProject)
  add_custom_target(GzPhysicsExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzPhysicsExternalProject)

  set(ROBOT_FARM_GZ_PHYSICS_URL
    "https://github.com/gazebosim/gz-physics/archive/refs/tags/gz-physics9_9.4.0.tar.gz"
    CACHE STRING
    "URL of the gz-physics source archive")

  externalproject_add(GzPhysicsExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-physics
    URL ${ROBOT_FARM_GZ_PHYSICS_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzPhysicsExternalProject
  Eigen3ExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzMathExternalProject
  GzPluginExternalProject
  GzUtilsExternalProject
  SdformatExternalProject)
