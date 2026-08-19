#[[ Cmake guard. ]]
if(TARGET GazeboExternalProject)
  return()
endif()

# Aggregate of gazebo sub-projects
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzFuelToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzGuiExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzLaunchExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPhysicsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzRenderingExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzSensorsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzSimExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzTransportExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SdformatExternalProject.cmake)

add_custom_target(GazeboExternalProject)

add_dependencies(GazeboExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzFuelToolsExternalProject
  GzGuiExternalProject
  GzLaunchExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzPhysicsExternalProject
  GzPluginExternalProject
  GzRenderingExternalProject
  GzSensorsExternalProject
  GzSimExternalProject
  GzToolsExternalProject
  GzTransportExternalProject
  GzUtilsExternalProject
  SdformatExternalProject)
