if(TARGET ZenohCppExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/ZenohCExternalProject.cmake)

option(ROBOT_FARM_SKIP_ZenohCppExternalProject "Forcefully skip zenoh-cpp" OFF)

if(ROBOT_FARM_SKIP_ZenohCppExternalProject)
  add_custom_target(ZenohCppExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST ZenohCppExternalProject)

  set(ROBOT_FARM_ZENOH_CPP_URL
    "https://github.com/eclipse-zenoh/zenoh-cpp/archive/refs/tags/1.10.0.tar.gz"
    CACHE STRING
    "URL of the zenoh-cpp source archive")

  externalproject_add(ZenohCppExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zenoh-cpp
    URL ${ROBOT_FARM_ZENOH_CPP_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DZENOHCXX_ZENOHC:BOOL=ON
    -DZENOHCXX_ZENOHPICO:BOOL=OFF
    -DZENOHCXX_ENABLE_TESTS:BOOL=OFF
    -DZENOHCXX_ENABLE_EXAMPLES:BOOL=OFF)
endif()

add_dependencies(ZenohCppExternalProject ZenohCExternalProject)
