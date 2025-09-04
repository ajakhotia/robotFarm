ARG OS_BASE=ubuntu:22.04

FROM ${OS_BASE} AS base

# Set dpkg to run in non-interactive mode.
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to return failure code if any command in the pipe fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo $'Acquire::http::Pipeline-Depth 0;\n\
    Acquire::http::No-Cache true;\n\
    Acquire::BrokenProxy    true;\n'\
    >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

RUN --mount=type=bind,src=tools,dst=/tools,ro                                                       \
    apt-get update &&                                                                               \
    apt-get full-upgrade -y --no-install-recommends &&                                              \
    apt-get autoclean -y &&                                                                         \
    apt-get autoremove -y &&                                                                        \
    apt-get install -y --no-install-recommends jq &&                                                \
    apt-get install -y --no-install-recommends $(bash /tools/apt/extractDependencies.sh Basics) &&  \
    bash /tools/installCMake.sh &&                                                                  \
    bash /tools/apt/addGNUSources.sh -y &&                                                          \
    bash /tools/apt/addLLVMSources.sh -y &&                                                         \
    bash /tools/apt/addNvidiaSources.sh -y &&                                                       \
    apt-get install -y --no-install-recommends $(bash /tools/apt/extractDependencies.sh Compilers)


FROM base AS build
ARG TOOLCHAIN=linux-gnu-12
ARG BUILD_LIST

RUN --mount=type=bind,src=.,dst=/tmp/robotFarm-src,ro                                               \
    cmake -E make_directory /tmp/robotFarm-build  &&                                                \
    cmake -E make_directory /opt/robotFarm &&                                                       \
    if [[ -z "${BUILD_LIST}" ]]; then                                                               \
        cmake -G Ninja                                                                              \
        -S /tmp/robotFarm-src                                                                       \
        -B /tmp/robotFarm-build                                                                     \
        -DCMAKE_BUILD_TYPE:STRING="Release"                                                         \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/tmp/robotFarm-src/cmake/toolchains/${TOOLCHAIN}.cmake      \
        -DCMAKE_INSTALL_PREFIX:PATH=/opt/robotFarm;                                                 \
    else                                                                                            \
        cmake -G Ninja                                                                              \
        -S /tmp/robotFarm-src                                                                       \
        -B /tmp/robotFarm-build                                                                     \
        -DCMAKE_BUILD_TYPE:STRING="Release"                                                         \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/tmp/robotFarm-src/cmake/toolchains/${TOOLCHAIN}.cmake      \
        -DCMAKE_INSTALL_PREFIX:PATH=/opt/robotFarm                                                  \
        -DROBOT_FARM_REQUESTED_BUILD_LIST:STRING=${BUILD_LIST};                                     \
    fi &&                                                                                           \
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends $(cat /tmp/robotFarm-build/systemDependencies.txt) &&\
    cmake --build /tmp/robotFarm-build  &&                                                          \
    rm -rf /tmp/robotFarm-build


FROM base AS deploy

COPY --from=build /opt/robotFarm /opt/robotFarm
RUN apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends $(cat /opt/robotFarm/systemDependencies.txt)
