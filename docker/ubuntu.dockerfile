# syntax=docker/dockerfile:1.7
ARG OS_BASE=ubuntu:22.04

FROM ${OS_BASE} AS base

# Set dpkg to run in non-interactive mode.
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to return failure code if any command in the pipe fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo -e 'path-exclude /usr/share/doc/*\npath-exclude /usr/share/man/*\npath-exclude /usr/share/locale/*\npath-exclude /usr/share/info/*' \
  > /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN echo $'Acquire::http::Pipeline-Depth 0;\n\
    Acquire::http::No-Cache true;\n\
    Acquire::BrokenProxy    true;\n'\
    >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

RUN --mount=type=bind,src=tools,dst=/tools,ro                                                       \
    --mount=type=cache,target=/var/cache/apt,sharing=locked                                         \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked                                     \
    apt-get update &&                                                                               \
    apt-get full-upgrade -y --no-install-recommends &&                                              \
    apt-get install -y --no-install-recommends jq &&                                                \
    apt-get install -y --no-install-recommends                                                      \
      $(bash /tools/apt/extractDependencies.sh Basics) &&                                           \
    bash /tools/installCMake.sh &&                                                                  \
    bash /tools/apt/addGNUSources.sh -y &&                                                          \
    bash /tools/apt/addLLVMSources.sh -y &&                                                         \
    bash /tools/apt/addNvidiaSources.sh -y &&                                                       \
    apt-get install -y --no-install-recommends                                                      \
      $(bash /tools/apt/extractDependencies.sh Compilers)


FROM base AS build
ARG TOOLCHAIN=linux-gnu-12
ARG BUILD_LIST

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    --mount=type=tmpfs,target=/tmp/robotFarm-build                                                  \
    --mount=type=cache,target=/var/cache/apt,sharing=locked                                         \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked                                     \
    cmake -E make_directory /opt/robotFarm &&                                                       \
    cmake -G Ninja                                                                                  \
      -S /tmp/robotFarm-src                                                                         \
      -B /tmp/robotFarm-build                                                                       \
      -DCMAKE_BUILD_TYPE=Release                                                                    \
      -DCMAKE_INSTALL_PREFIX=/opt/robotFarm                                                         \
      -DCMAKE_TOOLCHAIN_FILE=/tmp/robotFarm-src/cmake/toolchains/${TOOLCHAIN}.cmake                 \
      -DCMAKE_INSTALL_DO_STRIP=ON                                                                   \
      ${BUILD_LIST:+-DROBOT_FARM_REQUESTED_BUILD_LIST=${BUILD_LIST}} &&                             \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(cat /tmp/robotFarm-build/systemDependencies.txt) &&                                         \
    cmake --build /tmp/robotFarm-build


FROM base AS deploy

COPY --from=build /opt/robotFarm /opt/robotFarm

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked                                         \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked                                     \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends --fix-missing                                        \
      $(cat /opt/robotFarm/systemDependencies.txt)
