cmake_minimum_required(VERSION 3.22)

project(robotFarm VERSION 0.1.0.0 LANGUAGES C CXX CUDA Fortran)

# Cmake 3.24.1 improves the behaviour of external project by utilizing the time of
# extraction of the files from the downloaded source archive to determine the need
# for recompilation. We set the corresponding policy to new to leverage this benefit.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.24.1)
  cmake_policy(SET CMP0135 NEW)
endif()

set(BUILD_SHARED_LIBS OFF CACHE BOOL "Global flag to build shared libraries [Default: OFF]")
set(BUILD_TESTING OFF CACHE BOOL "Global flag used by CTest [Default: OFF]")
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Cmake build type [Default: Release]")

set(ROBOT_FARM_FORWARDED_CMAKE_ARGS
    $<$<BOOL:${CMAKE_TOOLCHAIN_FILE}>:-DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}>
    $<$<BOOL:${CMAKE_MAKE_PROGRAM}>:-DCMAKE_MAKE_PROGRAM:PATH=${CMAKE_MAKE_PROGRAM}>
    $<$<BOOL:${BUILD_SHARED_LIBS}>:-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}>
    $<$<BOOL:${BUILD_TESTING}>:-DBUILD_TESTING:BOOL=${BUILD_TESTING}>
    $<$<BOOL:${CMAKE_EXPORT_NO_PACKAGE_REGISTRY}>:-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=${CMAKE_EXPORT_NO_PACKAGE_REGISTRY}>
    $<$<BOOL:${CMAKE_EXPORT_PACKAGE_REGISTRY}>:-DCMAKE_EXPORT_PACKAGE_REGISTRY:BOOL=${CMAKE_EXPORT_PACKAGE_REGISTRY}>
    $<$<BOOL:${CMAKE_FIND_USE_PACKAGE_REGISTRY}>:-DCMAKE_FIND_USE_PACKAGE_REGISTRY:BOOL=${CMAKE_FIND_USE_PACKAGE_REGISTRY}>
    $<$<BOOL:${CMAKE_POLICY_VERSION_MINIMUM}>:-DCMAKE_POLICY_VERSION_MINIMUM=${CMAKE_POLICY_VERSION_MINIMUM}>)

if(CMAKE_BUILD_TYPE)
  list(APPEND ROBOT_FARM_FORWARDED_CMAKE_ARGS -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE})
endif()

set(PREFIX_PATH "")

if(CMAKE_INSTALL_PREFIX)
  list(APPEND ROBOT_FARM_FORWARDED_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX})
  list(APPEND PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
endif()

if(CMAKE_PREFIX_PATH)
  list(APPEND PREFIX_PATH ${CMAKE_PREFIX_PATH})
endif()

list(APPEND ROBOT_FARM_FORWARDED_CMAKE_ARGS -DCMAKE_PREFIX_PATH:STRING="${PREFIX_PATH}")

set(ROBOT_FARM_REQUESTED_BUILD_LIST
    AbseilExternalProject
    BoostExternalProject
    CapnprotoExternalProject
    CeresSolverExternalProject
    Eigen3ExternalProject
    FlatBuffersExternalProject
    GFlagsExternalProject
    GlogExternalProject
    GoogleTestExternalProject
    NlohmannJsonExternalProject
    OatppExternalProject
    OatppWebSocketExternalProject
    OgreExternalProject
    OpenCVExternalProject
    ProtobufExternalProject
    Python3ExternalProject
    SpdLogExternalProject
    SuiteSparseExternalProject
    VTKExternalProject
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
      COMMAND sh tools/apt/extractDependencies.sh ${ITEM}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE ITEM_DEPENDENCIES)

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

add_subdirectory(docker)
