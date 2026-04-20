add_custom_target(dockerUbuntu2204Image
    COMMAND
      bash -c "docker buildx build --progress=plain                                                 \
          --force-rm                                                                                \
          --target base                                                                             \
          --tag ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest                                \
          --build-arg OS_BASE=ubuntu:22.04                                                          \
          --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                                        \
          ${robotFarm_SOURCE_DIR}"
    WORKING_DIRECTORY
      ${robotFarm_SOURCE_DIR}
    COMMENT
      "Building robotFarm base image for ubuntu 22.04"
    VERBATIM
    USES_TERMINAL)

add_custom_target(dockerUbuntu2404Image
    COMMAND
      bash -c "docker buildx build --progress=plain                                                 \
          --force-rm                                                                                \
          --target base                                                                             \
          --tag ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest                                \
          --build-arg OS_BASE=ubuntu:24.04                                                          \
          --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                                        \
          ${robotFarm_SOURCE_DIR}"
    WORKING_DIRECTORY
      ${robotFarm_SOURCE_DIR}
    COMMENT
      "Building robotFarm base image for ubuntu 24.04"
    VERBATIM
    USES_TERMINAL)


#[[ Add a custom target that compiles robotFarm inside the given base image.
    Mirrors the CI build-package job: source is bind-mounted read-only, the build
    tree lives at /tmp/robotFarm-build, and ccache is persisted in a named docker
    volume derived from the image name so runs against the same image share it. ]]
function(robot_farm_add_docker_compile_target)
  set(options "")
  set(oneValueArgs TARGET_NAME IMAGE PRESET)
  set(multiValueArgs DEPENDS)
  cmake_parse_arguments(RF_DC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  string(REGEX REPLACE "[^a-zA-Z0-9]" "-" RF_DC_VOLUME "robotfarm-ccache-${RF_DC_IMAGE}")

  add_custom_target(${RF_DC_TARGET_NAME}
      COMMAND
        docker run --rm
          --volume ${robotFarm_SOURCE_DIR}:/tmp/robotFarm-src:ro
          --volume ${RF_DC_VOLUME}:/ccache
          --env CCACHE_DIR=/ccache
          --env CCACHE_MAXSIZE=20G
          ${RF_DC_IMAGE}
          bash -c "set -euo pipefail && \
            ccache --zero-stats && \
            cmake -S /tmp/robotFarm-src \
                  -B /tmp/robotFarm-build \
                  --preset ${RF_DC_PRESET} \
                  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
                  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache && \
            cmake --build   /tmp/robotFarm-build && \
            cmake --install /tmp/robotFarm-build && \
            ccache --show-stats"
      WORKING_DIRECTORY
        ${robotFarm_SOURCE_DIR}
      COMMENT
        "Compiling robotFarm in ${RF_DC_IMAGE} with preset ${RF_DC_PRESET}"
      VERBATIM
      USES_TERMINAL)

  if(RF_DC_DEPENDS)
    add_dependencies(${RF_DC_TARGET_NAME} ${RF_DC_DEPENDS})
  endif()
endfunction()

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Clang21Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      clang-21-shared
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Clang21Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      clang-21-static
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Clang22Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      clang-22-shared
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Clang22Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      clang-22-static
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Gnu14Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      gnu-14-shared
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Gnu14Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      gnu-14-static
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Gnu15Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      gnu-15-shared
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2204Gnu15Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest
    PRESET      gnu-15-static
    DEPENDS     dockerUbuntu2204Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Clang21Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      clang-21-shared
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Clang21Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      clang-21-static
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Clang22Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      clang-22-shared
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Clang22Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      clang-22-static
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Gnu14Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      gnu-14-shared
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Gnu14Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      gnu-14-static
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Gnu15Shared
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      gnu-15-shared
    DEPENDS     dockerUbuntu2404Image)

robot_farm_add_docker_compile_target(
    TARGET_NAME dockerUbuntu2404Gnu15Static
    IMAGE       ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest
    PRESET      gnu-15-static
    DEPENDS     dockerUbuntu2404Image)
