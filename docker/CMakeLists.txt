add_custom_target(robotFarmDockerBuildUbuntu2204LinuxGnu12
    COMMAND bash -c "docker buildx build                                                            \
                        --force-rm                                                                  \
                        --tag ghcr.io/ajakhotia/robotfarm/ubuntu-2204-linux-gnu-12/deploy:latest    \
                        --build-arg OS_BASE=ubuntu:22.04                                            \
                        --build-arg TOOLCHAIN=linux-gnu-12                                          \
                        --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                          \
                        ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm docker image for ubuntu 22.04 with linux-gnu-12"
    VERBATIM)

add_custom_target(robotFarmDockerBuildUbuntu2204LinuxClang19
    COMMAND bash -c "docker buildx build                                                            \
                        --force-rm                                                                  \
                        --tag ghcr.io/ajakhotia/robotfarm/ubuntu-2204-linux-clang-19/deploy:latest  \
                        --build-arg OS_BASE=ubuntu:22.04                                            \
                        --build-arg TOOLCHAIN=linux-clang-19                                        \
                        --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                          \
                        ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm docker image for ubuntu 22.04 with linux-clang-19"
    VERBATIM)

add_custom_target(robotFarmDockerBuildUbuntu2404LinuxGnu14
    COMMAND bash -c "docker buildx build                                                            \
                        --force-rm                                                                  \
                        --tag ghcr.io/ajakhotia/robotfarm/ubuntu-2404-linux-gnu-14/deploy:latest    \
                        --build-arg OS_BASE=ubuntu:24.04                                            \
                        --build-arg TOOLCHAIN=linux-gnu-14                                          \
                        --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                          \
                        ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm docker image for ubuntu 24.04 with linux-gnu-14"
    VERBATIM)

add_custom_target(robotFarmDockerBuildUbuntu2404LinuxClang19
    COMMAND bash -c "docker buildx build                                                            \
                        --force-rm                                                                  \
                        --tag ghcr.io/ajakhotia/robotfarm/ubuntu-2404-linux-clang-19/deploy:latest  \
                        --build-arg OS_BASE=ubuntu:24.04                                            \
                        --build-arg TOOLCHAIN=linux-clang-19                                        \
                        --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                          \
                        ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm docker image for ubuntu 24.04 with linux-clang-19"
    VERBATIM)
