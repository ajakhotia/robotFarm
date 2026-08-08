# syntax=docker/dockerfile:1.7
ARG OS_BASE=ubuntu:22.04

FROM ${OS_BASE} AS base

ARG OS_BASE
ENV OS_BASE=${OS_BASE}
ENV APT_VAR_CACHE_ID=robotfarm-apt-var-cache-${OS_BASE}
ENV APT_LIST_CACHE_ID=robotfarm-apt-list-cache-${OS_BASE}
ENV DEBIAN_FRONTEND=noninteractive

# The CUDA toolkit installs outside the default search paths. Put it on PATH so that builds
# resolve nvcc by default, mirroring how update-alternatives resolves the host compilers
# further down.
ENV PATH=/usr/local/cuda/bin:${PATH}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN printf '%s\n'                                                                                  \
    'path-exclude /usr/share/doc/*'                                                                \
    'path-exclude /usr/share/man/*'                                                                \
    'path-include /usr/share/locale/locale.alias'                                                  \
    'path-include /usr/share/locale/en*/*'                                                         \
    'path-exclude /usr/share/locale/*'                                                             \
    'path-exclude /usr/share/info/*'                                                               \
    > /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN printf '%s\n'                                                                                  \
    'Acquire::http::Pipeline-Depth 0;'                                                             \
    'Acquire::https::Pipeline-Depth 0;'                                                            \
    'Acquire::http::No-Cache true;'                                                                \
    'Acquire::https::No-Cache true;'                                                               \
    'Acquire::BrokenProxy    true;'                                                                \
    >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

# Make apt resilient to flaky upstreams (e.g., Launchpad PPA hosting under stress):
# 5 retries with short per-request timeouts so each failed attempt fails fast and
# we get more shots at reaching a healthy backend behind the load balancer.
RUN printf '%s\n'                                                                                  \
    'Acquire::Retries "5";'                                                                        \
    'Acquire::http::Timeout "30";'                                                                 \
    'Acquire::https::Timeout "30";'                                                                \
    > /etc/apt/apt.conf.d/91retry-and-timeouts

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                 \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked            \
    apt-get update &&                                                                              \
    apt-get full-upgrade -y --no-install-recommends &&                                             \
    apt-get autoremove -y --no-install-recommends &&                                               \
    apt-get autoclean -y --no-install-recommends

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                  \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked             \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends                                                      \
      ca-certificates curl gnupg jq software-properties-common

RUN --mount=type=bind,src=external/infraCommons/tools/apt/addAptSources.sh,dst=/tmp/tools/apt/addAptSources.sh,ro       \
    bash /tmp/tools/apt/addAptSources.sh -y

RUN --mount=type=cache,target=/var/cache/apt,id=${APT_VAR_CACHE_ID},sharing=locked                                      \
    --mount=type=cache,target=/var/lib/apt/lists,id=${APT_LIST_CACHE_ID},sharing=locked                                 \
    --mount=type=bind,src=external/infraCommons/tools/extractDependencies.sh,dst=/tmp/tools/extractDependencies.sh,ro   \
    --mount=type=bind,src=systemDependencies.json,dst=/tmp/systemDependencies.json,ro                                   \
    apt-get update &&                                                                                                   \
    apt-get install -y --no-install-recommends                                                                          \
      $(sh /tmp/tools/extractDependencies.sh Basics /tmp/systemDependencies.json)

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

# apt.llvm.org's libomp-N-dev packages all Provide and Conflict on the
# virtual package libomp-x.y-dev, so only one major can be installed at a
# time. We pick libomp-22-dev (matches clang-22's resource dir natively)
# and expose its omp.h to clang-21. The runtime libomp.so comes from
# /usr/lib/llvm-22 via linker flags in linux-clang-21.cmake.
# Register the newest installed GNU compilers as the defaults for the unversioned names.
RUN gnu=$(ls /usr/bin | grep -E '^gcc-[0-9]+$' | sort -V | tail -n 1 | cut -d- -f2) &&              \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gnu} 100                          \
      --slave /usr/bin/g++ g++ /usr/bin/g++-${gnu}                                                  \
      --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-${gnu} &&                                \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 &&                                \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100

# Register the newest installed LLVM compilers as the defaults for the unversioned clang names.
RUN llvm=$(ls /usr/bin | grep -E '^clang-[0-9]+$' | sort -V | tail -n 1 | cut -d- -f2) &&           \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${llvm} 100                   \
      --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${llvm}                                     \
      --slave /usr/bin/flang flang /usr/bin/flang-${llvm}

RUN ln -s /usr/lib/llvm-22/lib/clang/22/include/omp.h                                                                   \
          /usr/lib/llvm-21/lib/clang/21/include/omp.h
