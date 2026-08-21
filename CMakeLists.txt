cmake_minimum_required(VERSION 3.22)

include(${CMAKE_CURRENT_SOURCE_DIR}/external/infraCommons/cmake/utilities/forwardedCacheArgs.cmake)

#[[ Record which cache entries the user handed this configure while they are still
    identifiable: project() and later cache declarations erase the command-line marker from
    untyped -D entries. The recorded names feed compose_forwarded_cache_args below. ]]
capture_user_cache_entries(OUTPUT_VARIABLE ROBOT_FARM_USER_CACHE_ENTRIES)

project(robotFarm VERSION 0.1.0.0 LANGUAGES C CXX CUDA Fortran)

# Cmake 3.24.1 improves the behaviour of external project by utilizing the time of
# extraction of the files from the downloaded source archive to determine the need
# for recompilation. We set the corresponding policy to new to leverage this benefit.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.24.1)
  cmake_policy(SET CMP0135 NEW)
endif()


#[[ Setup project level tools and external dependencies if and only if this project
    is the top-level project. If this project has been included with-in another
    project as a submodule, then the onus of setting up these requirement falls on that
    top-level project. This prevent this project from overreaching when it is used as a submodule
    in another project. ]]
if(PROJECT_IS_TOP_LEVEL)
  add_subdirectory(external)
  add_subdirectory(docker)
endif()


set(BUILD_SHARED_LIBS OFF CACHE BOOL "Global flag to build shared libraries [Default: OFF]")
set(BUILD_TESTING OFF CACHE BOOL "Global flag used by CTest [Default: OFF]")
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Cmake build type [Default: Release]")

# In-band list separator for values forwarded through ExternalProject_Add. The helper below
# escapes list values with it, and each ExternalProject_Add call pairs it with LIST_SEPARATOR
# so that `|` is translated back to `;` in the child's configure.
set(ROBOT_FARM_LIST_SEPARATOR "|")

#[[ Policy this super build imposes on every external project, forwarded by effective value
    through compose_forwarded_cache_args below. A name belongs in FORWARD_VARIABLES only if
    this super build authors its value (the set() calls below and the defaults above) or
    composes it (CMAKE_PREFIX_PATH gains the install prefix so children resolve packages
    installed by their siblings). Everything the user hands this configure (raw -D
    definitions, a preset's cacheVariables, a toolchain file) is forwarded by the helper
    automatically and needs no listing here, except names in this super build's own
    ROBOT_FARM_ namespace: those are its interface, consumed at this level, and are excluded
    from forwarding. ]]
set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON)
set(CMAKE_EXPORT_PACKAGE_REGISTRY OFF)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY OFF)
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)

# Static archives must be position-independent so that the language binding modules, which
# are shared objects even in static builds, can link them.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(CMAKE_INSTALL_PREFIX)
  list(PREPEND CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
endif()

compose_forwarded_cache_args(
  OUTPUT_VARIABLE ROBOT_FARM_FORWARDED_CMAKE_ARGS
  LIST_SEPARATOR ${ROBOT_FARM_LIST_SEPARATOR}
  USER_ENTRIES ${ROBOT_FARM_USER_CACHE_ENTRIES}
  EXCLUDE_PREFIXES ROBOT_FARM_
  FORWARD_VARIABLES
    BUILD_SHARED_LIBS
    BUILD_TESTING
    CMAKE_BUILD_TYPE
    CMAKE_EXPORT_NO_PACKAGE_REGISTRY
    CMAKE_EXPORT_PACKAGE_REGISTRY
    CMAKE_FIND_USE_PACKAGE_REGISTRY
    CMAKE_INSTALL_RPATH
    CMAKE_INSTALL_RPATH_USE_LINK_PATH
    CMAKE_POLICY_VERSION_MINIMUM
    CMAKE_POSITION_INDEPENDENT_CODE
    CMAKE_PREFIX_PATH)

#[[ Upstream gz does not support static consumption: gz-rendering fails to export its
    vendored terra target, and the installed static configs of gz-common and gz-plugin
    reference TINYXML2::TINYXML2 and DL::DL targets that consumers cannot resolve. Static
    builds therefore skip the projects that consume those configs; the base gz libraries,
    gz-transport, and sdformat build statically and stay in. ]]
if(NOT BUILD_SHARED_LIBS)
  set(ROBOT_FARM_SKIP_GzFuelToolsExternalProject ON)
  set(ROBOT_FARM_SKIP_GzGuiExternalProject ON)
  set(ROBOT_FARM_SKIP_GzLaunchExternalProject ON)
  set(ROBOT_FARM_SKIP_GzPhysicsExternalProject ON)
  set(ROBOT_FARM_SKIP_GzRenderingExternalProject ON)
  set(ROBOT_FARM_SKIP_GzSensorsExternalProject ON)
  set(ROBOT_FARM_SKIP_GzSimExternalProject ON)
endif()

set(ROBOT_FARM_REQUESTED_BUILD_LIST
  AbseilExternalProject
  BoostExternalProject
  CapnprotoExternalProject
  CeresSolverExternalProject
  CudssExternalProject
  Eigen3ExternalProject
  FlatBuffersExternalProject
  GFlagsExternalProject
  GazeboExternalProject
  GlogExternalProject
  GoogleTestExternalProject
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
  NlohmannJsonExternalProject
  OatppExternalProject
  OatppWebSocketExternalProject
  OgreExternalProject
  OpenCVExternalProject
  ProtobufExternalProject
  Python3ExternalProject
  SdformatExternalProject
  SpdLogExternalProject
  SuiteSparseExternalProject
  VTKExternalProject
  ZenohCExternalProject
  ZenohCppExternalProject
  CACHE STRING
  "Semi-colon separated list of projects requested by the user. Default includes all")

set(ROBOT_FARM_BUILD_LIST "")

foreach(ITEM ${ROBOT_FARM_REQUESTED_BUILD_LIST})
  include(${CMAKE_CURRENT_SOURCE_DIR}/externalProjects/${ITEM}.cmake)
endforeach()


function(print_list label)
  set(_lines "")
  foreach(_it IN LISTS ARGN)
    string(APPEND _lines "\t${_it}\n")
  endforeach()
  if(label)
    message(STATUS "${label}:\n${_lines}")
  else()
    message(STATUS "${_lines}")
  endif()
endfunction()

print_list("User requested the build of" ${ROBOT_FARM_REQUESTED_BUILD_LIST})
print_list("RobotFarm will build" ${ROBOT_FARM_BUILD_LIST})

set(ROBOT_FARM_SYSTEM_DEPENDENCY_STR "")
foreach(ITEM ${ROBOT_FARM_BUILD_LIST})
  execute_process(
    COMMAND sh external/infraCommons/tools/extractDependencies.sh ${ITEM} systemDependencies.json
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE ITEM_DEPENDENCIES
    COMMAND_ERROR_IS_FATAL ANY)

  if(ITEM_DEPENDENCIES)
    string(APPEND ROBOT_FARM_SYSTEM_DEPENDENCY_STR " " ${ITEM_DEPENDENCIES})
  endif()
endforeach()

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/systemDependencies.txt "${ROBOT_FARM_SYSTEM_DEPENDENCY_STR}")

add_custom_command(
  OUTPUT ${CMAKE_INSTALL_PREFIX}/systemDependencies.txt
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/systemDependencies.txt ${CMAKE_INSTALL_PREFIX}/systemDependencies.txt
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/systemDependencies.txt
  COMMENT "Installing ${CMAKE_CURRENT_BINARY_DIR}/systemDependencies.txt to ${CMAKE_INSTALL_PREFIX}/systemDependencies.txt")

add_custom_target(systemDependenciesManifest ALL DEPENDS ${CMAKE_INSTALL_PREFIX}/systemDependencies.txt)
