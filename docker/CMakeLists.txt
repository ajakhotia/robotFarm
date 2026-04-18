#[[ Local convenience targets for building the base image used by CI.
    The library build itself no longer runs through `docker build` — it runs via
    `docker run` with presets in the CI workflow (see .github/workflows/docker-image.yaml). ]]

foreach(OS_VARIANT IN ITEMS "ubuntu-22-04;ubuntu:22.04" "ubuntu-24-04;ubuntu:24.04")
  list(GET OS_VARIANT 0 OS_SLUG)
  list(GET OS_VARIANT 1 OS_BASE)

  add_custom_target(robotFarmDockerBuildBase_${OS_SLUG}
      COMMAND
        bash -c "docker buildx build --progress=plain                                           \
            --force-rm                                                                          \
            --target base                                                                       \
            --tag ghcr.io/ajakhotia/robotfarm/${OS_SLUG}/base:latest                            \
            --build-arg OS_BASE=${OS_BASE}                                                      \
            --file ${CMAKE_CURRENT_LIST_DIR}/ubuntu.dockerfile                                  \
            ${robotFarm_SOURCE_DIR}"
      WORKING_DIRECTORY
        ${robotFarm_SOURCE_DIR}
      COMMENT
        "Building robotFarm base image for ${OS_BASE}"
      VERBATIM
      USES_TERMINAL)
endforeach()
