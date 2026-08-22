if(TARGET ZenohCExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_ZenohCExternalProject "Forcefully skip zenoh-c" OFF)

if(ROBOT_FARM_SKIP_ZenohCExternalProject)
  add_custom_target(ZenohCExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST ZenohCExternalProject)

  set(ROBOT_FARM_ZENOH_C_URL
    "https://github.com/eclipse-zenoh/zenoh-c/archive/refs/tags/1.10.0.tar.gz"
    CACHE STRING
    "URL of the zenoh-c source archive")

  #[[ zenoh-c is a Rust crate behind a CMake facade. The build drives the system cargo, which
      fetches crate dependencies at build time. Shared memory and the unstable API are enabled
      to match the surface the ROS 2 zenoh vendor package exposes to gz-transport. ]]
  externalproject_add(ZenohCExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zenoh-c
    URL ${ROBOT_FARM_ZENOH_C_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DZENOHC_BUILD_WITH_SHARED_MEMORY:BOOL=ON
    -DZENOHC_BUILD_WITH_UNSTABLE_API:BOOL=ON)
endif()
