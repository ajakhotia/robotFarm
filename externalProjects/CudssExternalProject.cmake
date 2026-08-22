#[[ Cmake guard. ]]
if(TARGET CudssExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_CudssExternalProject "Forcefully skip cuDSS" OFF)

if(ROBOT_FARM_SKIP_CudssExternalProject)
  add_custom_target(CudssExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST CudssExternalProject)

  #[[ cuDSS is NVIDIA's closed-source direct sparse solver, distributed only as prebuilt
      binaries. This recipe consumes the pinned redist archive (the same bits as NVIDIA's
      apt packages, without requiring their extra repository on every host) and installs
      its include/, lib/ and cudss-config.cmake into the prefix, where consumers such as
      Ceres resolve it through CMAKE_PREFIX_PATH. The published sha256 guards the binary
      artifact. ]]
  set(ROBOT_FARM_CUDSS_URL
    "https://developer.download.nvidia.com/compute/cudss/redist/libcudss/linux-x86_64/libcudss-linux-x86_64-0.8.0.10_cuda13-archive.tar.xz"
    CACHE STRING
    "URL of the cuDSS prebuilt binary archive")

  set(ROBOT_FARM_CUDSS_URL_HASH
    "SHA256=ba18f5fd80dcbbe905d158caac5b3061d848442bb5abd477b5f296b4257a4937"
    CACHE STRING
    "Hash of the cuDSS prebuilt binary archive")

  externalproject_add(CudssExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/cudss
    URL ${ROBOT_FARM_CUDSS_URL}
    URL_HASH ${ROBOT_FARM_CUDSS_URL_HASH}
    DOWNLOAD_NO_PROGRESS ON
    #[[ The shipped config promotes its imported targets to global scope unconditionally,
        which CMake rejects when a second directory includes the config. Guard the config
        with an early return so only the first inclusion creates and promotes. ]]
    PATCH_COMMAND sed -i
      "1i # robotFarm: return early when already loaded. The IMPORTED_GLOBAL promotion\\n# below fails when a second directory includes this config.\\nif(TARGET cudss)\\n    return()\\nendif()"
      lib/cmake/cudss/cudss-config.cmake
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include ${CMAKE_INSTALL_PREFIX}/include
    COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib ${CMAKE_INSTALL_PREFIX}/lib
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/share/licenses/cudss
    COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/LICENSE ${CMAKE_INSTALL_PREFIX}/share/licenses/cudss/LICENSE)
endif()
