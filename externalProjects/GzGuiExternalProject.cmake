if(TARGET GzGuiExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMsgsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzRenderingExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzToolsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzTransportExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtobufExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzGuiExternalProject "Forcefully skip gz-gui" OFF)

if(ROBOT_FARM_SKIP_GzGuiExternalProject)
  add_custom_target(GzGuiExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzGuiExternalProject)

  set(ROBOT_FARM_GZ_GUI_URL
    "https://github.com/gazebosim/gz-gui/archive/refs/tags/gz-gui10_10.0.0.tar.gz"
    CACHE STRING
    "URL of the gz-gui source archive")

  externalproject_add(GzGuiExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-gui
    URL ${ROBOT_FARM_GZ_GUI_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()

add_dependencies(GzGuiExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzMathExternalProject
  GzMsgsExternalProject
  GzPluginExternalProject
  GzRenderingExternalProject
  GzToolsExternalProject
  GzTransportExternalProject
  GzUtilsExternalProject
  ProtobufExternalProject)
