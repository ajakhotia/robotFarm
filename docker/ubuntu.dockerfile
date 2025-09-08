# syntax=docker/dockerfile:1.7
ARG OS_BASE=ubuntu:22.04

FROM ${OS_BASE} AS base
ARG OS_BASE
ENV OS_BASE=${OS_BASE}
ENV APT_VAR_CACHE_ID=robotfarm-apt-var-cache-${OS_BASE}
ENV APT_LIST_CACHE_ID=robotfarm-apt-list-cache-${OS_BASE}
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to return failure code if any command in the pipe fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN printf '%s\n'                                                                                   \
  'path-exclude /usr/share/doc/*'                                                                   \
  'path-exclude /usr/share/man/*'                                                                   \
  'path-include /usr/share/locale/locale.alias'                                                     \
  'path-include /usr/share/locale/en*/*'                                                            \
  'path-exclude /usr/share/locale/*'                                                                \
  'path-exclude /usr/share/info/*'                                                                  \
  > /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN printf '%s\n'                                                                                   \
  'Acquire::http::Pipeline-Depth 0;'                                                                \
  'Acquire::http::No-Cache true;'                                                                   \
  'Acquire::BrokenProxy    true;'                                                                   \
  >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    apt-get update &&                                                                               \
    apt-get full-upgrade -y --no-install-recommends &&                                              \
    apt-get autoremove &&                                                                           \
    apt-get autoclean

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends jq

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=bind,src=tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro     \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro               \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(sh /tmp/tools/extractDependencies.sh Basics /tmp/systemDependencies.json)

RUN --mount=type=bind,src=tools/installCMake.sh,dst=/tmp/tools/installCMake.sh,ro                   \
    bash /tmp/tools/installCMake.sh

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=bind,src=tools/apt/addGNUSources.sh,dst=/tmp/tools/apt/addGNUSources.sh,ro         \
    bash /tmp/tools/apt/addGNUSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=bind,src=tools/apt/addLLVMSources.sh,dst=/tmp/tools/apt/addLLVMSources.sh,ro       \
    bash /tmp/tools/apt/addLLVMSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=bind,src=tools/apt/addNvidiaSources.sh,dst=/tmp/tools/apt/addNvidiaSources.sh,ro   \
    bash /tmp/tools/apt/addNvidiaSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=bind,src=tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro     \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro               \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(bash /tmp/tools/extractDependencies.sh Compilers /tmp/systemDependencies.json)


FROM base AS build
ARG BUILD_LIST
ARG TOOLCHAIN=linux-gnu-12

ENV ROBOTFARM_BUILD_TREE_ID=robotfarm-build-${OS_BASE}-${TOOLCHAIN}

RUN cmake -E make_directory /opt/robotFarm

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    --mount=type=cache,target=/tmp/robotFarm-build,id=${ROBOTFARM_BUILD_TREE_ID}                    \
    cmake -G Ninja                                                                                  \
      -S /tmp/robotFarm-src                                                                         \
      -B /tmp/robotFarm-build                                                                       \
      -U *                                                                                          \
      -DCMAKE_BUILD_TYPE=Release                                                                    \
      -DCMAKE_INSTALL_PREFIX=/opt/robotFarm                                                         \
      -DCMAKE_TOOLCHAIN_FILE=/tmp/robotFarm-src/cmake/toolchains/${TOOLCHAIN}.cmake                 \
      -DCMAKE_INSTALL_DO_STRIP=ON                                                                   \
      ${BUILD_LIST:+-DROBOT_FARM_REQUESTED_BUILD_LIST=${BUILD_LIST}}

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    --mount=type=cache,target=/tmp/robotFarm-build,id=${ROBOTFARM_BUILD_TREE_ID}                    \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      $(cat /tmp/robotFarm-build/systemDependencies.txt)

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    --mount=type=cache,target=/tmp/robotFarm-build,id=${ROBOTFARM_BUILD_TREE_ID}                    \
    cmake --build /tmp/robotFarm-build

FROM base AS deploy

COPY --from=build /opt/robotFarm /opt/robotFarm

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends --fix-missing                                        \
      $(cat /opt/robotFarm/systemDependencies.txt)
