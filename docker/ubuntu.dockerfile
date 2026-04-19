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
    apt-get autoremove -y --no-install-recommends &&                                                \
    apt-get autoclean -y --no-install-recommends

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends jq

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro   \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro                                   \
    apt-get update &&                                                                                                   \
    apt-get install -y --no-install-recommends                                                                          \
      $(sh /tmp/tools/extractDependencies.sh Basics /tmp/systemDependencies.json)

RUN --mount=type=bind,src=external/infraCommons/tools/installCMake.sh,dst=/tmp/tools/installCMake.sh,ro                 \
    bash /tmp/tools/installCMake.sh

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/apt/addGNUSources.sh,dst=/tmp/tools/apt/addGNUSources.sh,ro       \
    bash /tmp/tools/apt/addGNUSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/apt/addLLVMSources.sh,dst=/tmp/tools/apt/addLLVMSources.sh,ro     \
    bash /tmp/tools/apt/addLLVMSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/apt/addNvidiaSources.sh,dst=/tmp/tools/apt/addNvidiaSources.sh,ro \
    bash /tmp/tools/apt/addNvidiaSources.sh -y

# Install the compiler toolchains together with the per-external-project
# system dependencies for every project compiled inside this image. Groups
# without an entry in systemDependencies.json are silently skipped by the
# script, so listing every externalProjects/*.cmake entry is safe.
RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro   \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro                                   \
    apt-get update &&                                                                                                   \
    apt-get install -y --no-install-recommends                                                                          \
      $(sh /tmp/tools/extractDependencies.sh                                                                            \
          "Compilers                                                                                                    \
           AbseilExternalProject                                                                                        \
           BoostExternalProject                                                                                         \
           CapnprotoExternalProject                                                                                     \
           CeresSolverExternalProject                                                                                   \
           Eigen3ExternalProject                                                                                        \
           FlatBuffersExternalProject                                                                                   \
           GFlagsExternalProject                                                                                        \
           GlogExternalProject                                                                                          \
           GoogleTestExternalProject                                                                                    \
           NlohmannJsonExternalProject                                                                                  \
           OatppExternalProject                                                                                         \
           OatppWebSocketExternalProject                                                                                \
           OgreExternalProject                                                                                          \
           OpenCVExternalProject                                                                                        \
           ProtobufExternalProject                                                                                      \
           Python3ExternalProject                                                                                       \
           SpdLogExternalProject                                                                                        \
           SuiteSparseExternalProject                                                                                   \
           VTKExternalProject"                                                                                          \
          /tmp/systemDependencies.json)
