# syntax=docker/dockerfile:1.7
ARG OS_BASE=ubuntu:22.04

FROM ${OS_BASE} AS base

ENV OS_BASE=${OS_BASE}
ENV APT_CACHE_ID=robotfarm-apt-${OS_BASE}
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to return failure code if any command in the pipe fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo -e 'path-exclude /usr/share/doc/*\npath-exclude /usr/share/man/*\npath-exclude /usr/share/locale/*\npath-exclude /usr/share/info/*' \
  > /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN echo $'Acquire::http::Pipeline-Depth 0;\n\
    Acquire::http::No-Cache true;\n\
    Acquire::BrokenProxy    true;\n'\
    >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    apt-get update &&                                                                               \
    apt-get full-upgrade -y --no-install-recommends &&                                              \
    apt-get autoremove &&                                                                           \
    apt-get autoclean

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends jq

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    --mount=type=bind,src=tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro     \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro               \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(sh /tmp/tools/extractDependencies.sh Basics /tmp/systemDependencies.json)

RUN --mount=type=bind,src=tools/installCMake.sh,dst=/tmp/tools/installCMake.sh,ro                   \
    bash /tmp/tools/installCMake.sh

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    --mount=type=bind,src=tools/apt/addGNUSources.sh,dst=/tmp/tools/apt/addGNUSources.sh,ro         \
    bash /tmp/tools/apt/addGNUSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    --mount=type=bind,src=tools/apt/addLLVMSources.sh,dst=/tmp/tools/apt/addLLVMSources.sh,ro       \
    bash /tmp/tools/apt/addLLVMSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    --mount=type=bind,src=tools/apt/addNvidiaSources.sh,dst=/tmp/tools/apt/addNvidiaSources.sh,ro   \
    bash /tmp/tools/apt/addNvidiaSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    --mount=type=bind,src=tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro     \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro               \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(bash /tmp/tools/extractDependencies.sh Compilers /tmp/systemDependencies.json)


FROM base AS build
ARG BUILD_LIST
ARG TOOLCHAIN=linux-gnu-12

ENV BUILD_TREE_ID=robotfarm-build-${OS_BASE}-${TOOLCHAIN}

RUN cmake -E make_directory /opt/robotFarm

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    --mount=type=cache,target=/tmp/robotFarm-build,id=${BUILD_TREE_ID}                              \
    cmake -G Ninja                                                                                  \
      -S /tmp/robotFarm-src                                                                         \
      -B /tmp/robotFarm-build                                                                       \
      -DCMAKE_BUILD_TYPE=Release                                                                    \
      -DCMAKE_INSTALL_PREFIX=/opt/robotFarm                                                         \
      -DCMAKE_TOOLCHAIN_FILE=/tmp/robotFarm-src/cmake/toolchains/${TOOLCHAIN}.cmake                 \
      -DCMAKE_INSTALL_DO_STRIP=ON                                                                   \
      ${BUILD_LIST:+-DROBOT_FARM_REQUESTED_BUILD_LIST=${BUILD_LIST}}

RUN --mount=type=cache,target=/tmp/robotFarm-build,id=${BUILD_TREE_ID}                              \
    --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(cat /tmp/robotFarm-build/systemDependencies.txt)

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    --mount=type=cache,target=/tmp/robotFarm-build,id=${BUILD_TREE_ID}                              \
    cmake --build /tmp/robotFarm-build

FROM base AS deploy

COPY --from=build /opt/robotFarm /opt/robotFarm

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_CACHE_ID},sharing=locked                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_CACHE_ID},sharing=locked                  \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends --fix-missing                                        \
      $(cat /opt/robotFarm/systemDependencies.txt)
