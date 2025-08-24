add_custom_target(robotFarmDockerBuildUbuntu2204
    COMMAND bash -c "docker buildx build                                                    \
                        --force-rm                                                          \
                        --tag robotfarm/build-ubuntu-2204                                   \
                        --build-arg BASE_IMAGE=ubuntu:22.04                                 \
                        --file ${CMAKE_CURRENT_LIST_DIR}/robotFarm-ubuntu.dockerfile        \
                        ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm in docker container."
    VERBATIM)

add_custom_target(robotFarmDockerBuildUbuntu2404
    COMMAND bash -c "docker buildx build                                                    \
                            --force-rm                                                      \
                            --tag robotfarm/build-ubuntu-2404                               \
                            --build-arg BASE_IMAGE=ubuntu:24.04                             \
                            --file ${CMAKE_CURRENT_LIST_DIR}/robotFarm-ubuntu.dockerfile    \
                            ${robotFarm_SOURCE_DIR}"

    WORKING_DIRECTORY ${robotFarm_SOURCE_DIR}
    COMMENT "Building robotFarm in docker container."
    VERBATIM)
