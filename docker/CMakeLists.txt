add_custom_target(robotFarmDockerBuildUbuntu2204
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

add_custom_target(robotFarmDockerBuildUbuntu2404
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
