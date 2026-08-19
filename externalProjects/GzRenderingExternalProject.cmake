#[[ Cmake guard. ]]
if(TARGET GzRenderingExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GzCmakeExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzCommonExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzMathExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzPluginExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GzUtilsExternalProject.cmake)

option(ROBOT_FARM_SKIP_GzRenderingExternalProject "Forcefully skip gz-rendering" OFF)

if(ROBOT_FARM_SKIP_GzRenderingExternalProject)
  add_custom_target(GzRenderingExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GzRenderingExternalProject)

  set(ROBOT_FARM_GZ_RENDERING_URL
    "https://github.com/gazebosim/gz-rendering/archive/refs/tags/gz-rendering10_10.0.2.tar.gz"
    CACHE STRING
    "URL of the gz-rendering source archive")

  #[[ The ogre1 render engine is skipped: Ubuntu 26.04 dropped libogre-dev, and
      OgreExternalProject carries OGRE 14, which gz-rendering's ogre1 plugin does not support.
      ogre2 on the packaged ogre-next 2.3 is the engine gz-sim defaults to anyway. ]]
  externalproject_add(GzRenderingExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gz-rendering
    URL ${ROBOT_FARM_GZ_RENDERING_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DSKIP_ogre:BOOL=ON
    -DSKIP_optix:BOOL=ON)
endif()

add_dependencies(GzRenderingExternalProject
  GzCmakeExternalProject
  GzCommonExternalProject
  GzMathExternalProject
  GzPluginExternalProject
  GzUtilsExternalProject)
