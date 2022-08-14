ARG BASE_IMAGE=ubuntu:22.04
ARG TOOLCHAIN=gnu-12

FROM ${BASE_IMAGE} AS robot-farm-base

# Set dpkg to run in non-interactive mode.
ENV DEBIAN_FRONTEND=noninteractive

# Set shell to return failure code if any command in the pipe fails.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo $'Acquire::http::Pipeline-Depth 0;\n\
    Acquire::http::No-Cache true;\n\
    Acquire::BrokenProxy    true;\n'\
    >> /etc/apt/apt.conf.d/90fix-hashsum-mismatch

RUN apt-get update &&                                   \
    apt-get install -y --no-install-recommends jq &&    \
    apt-get full-upgrade -y &&                          \
    apt-get autoclean -y &&                             \
    apt-get autoremove -y

COPY ./scripts /tmp/scripts
RUN apt-get install -y --no-install-recommends $(sh /tmp/scripts/extractDependencies.sh Basics) && \
    rm -rf /tmp/scripts


FROM robot-farm-base AS throwaway-robot-farm-build
ARG TOOLCHAIN

COPY . /tmp/robotFarm-src

RUN cmake -G Ninja                                                              \
    -S /tmp/robotFarm-src                                                       \
    -B /tmp/robotFarm-build                                                     \
    -DCMAKE_BUILD_TYPE:STRING="Release"                                         \
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/tmp/robotFarm-src/toolchains/${TOOLCHAIN}.cmake  \
    -DCMAKE_INSTALL_PREFIX:PATH=/opt/robotFarm

RUN apt-get install -y --no-install-recommends $(cat /tmp/robotFarm-build/systemDependencies.txt)

RUN cmake --build /tmp/robotFarm-build


FROM robot-farm-base AS robot-farm
COPY --from=throwaway-robot-farm-build /opt/robotFarm /opt/robotFarm
COPY --from=throwaway-robot-farm-build /tmp/robotFarm-build/systemDependencies.txt /tmp/systemDependencies.txt
RUN apt-get install -y --no-install-recommends $(cat /tmp/systemDependencies.txt) && \
    rm -rf /tmp/systemDependencies.txt
