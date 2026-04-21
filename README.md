[![docker-image](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml)

# 🚜 robotFarm

`robotFarm` is a CMake super-build for common AI and robotics libraries. It downloads, builds, and
installs the libraries from source, handles the dependencies between them, and tells you which
system packages to install with your OS package manager. Each library is built with the full set of
supported features so downstream projects can use them without having to rebuild.

## 🌱 Why use robotFarm?

* **Up to date and flexible**: get the latest stable versions, or pick specific versions with CMake
  command-line options.
* **Efficient**: build once, install to a prefix, reuse across projects.
* **Consistent**: every library's configuration is documented, and each build turns on the full set
  of features so downstream code can rely on them.

## 📚 Supported libraries

- absl
- AMD
- Boost
- CAMD
- CapnProto
- CCOLAMD
- Ceres
- CHOLMOD
- COLAMD
- Eigen3
- flatbuffers
- Gflags
- Glog
- GTest
- nlohmann_json
- oatpp
- oatpp-websocket
- OGRE
- OpenCV
- protobuf
- Python3
- spdlog
- SPQR
- SuiteSparse_config
- VTK

## ⚡ Quick Start

The full instructions are in the [Slow Start](#-slow-start) section. If you just want to get started
quickly, pick one of the options below.

> If you plan to use robotFarm as the base for your own project, or expect to rebuild it often,
> the [Slow Start](#-slow-start) section is the better place to start.

### 📦 Prebuilt release tarballs

Every tagged release (`v*`) attaches a set of zstd-compressed install archives to the GitHub release
page — one archive for each combination of OS version and
[CMake preset](#cmake-presets). Download the archive that matches your OS and toolchain, then
extract it under `/opt`:

```shell
tar --zstd -C /opt -xf robotFarm-ubuntu-24-04-gnu-15-shared-<version>.tar.zst
```

The archive also contains a `systemDependencies.txt` file at the install root. It lists the system
packages the libraries need at runtime. On Ubuntu, pass this file to apt:

```shell
sudo apt update && sudo apt install -y --no-install-recommends $(cat /opt/robotFarm/systemDependencies.txt)
```

On other distributions, install the same packages using your package manager.

Browse available archives on the
[releases page](https://github.com/ajakhotia/robotFarm/releases).

### 🐳 Prebuilt base images

CI publishes a base image per supported Ubuntu version. Each image has the compilers, apt
dependencies, and a recent `cmake` already installed. Use it to build robotFarm (or a project that
depends on it) inside a clean container without installing the toolchain yourself:

* `ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest`

These images only contain the build environment — robotFarm itself is not installed. Replace
`latest` with a commit SHA tag to use a specific version.

To build the same image locally, use the command below. `OS_BASE` is the only build argument you
need (for example, `ubuntu:22.04` or `ubuntu:24.04`):

```shell
git clone https://github.com/ajakhotia/robotFarm.git /tmp/robotFarm-src && \
docker buildx build                                         \
  --tag robotfarm-base                                      \
  --file /tmp/robotFarm-src/docker/ubuntu.dockerfile        \
  --build-arg OS_BASE=ubuntu:24.04                          \
  /tmp/robotFarm-src
```

To run the build inside a container and copy the finished install-tree to the host, use the command
below:

```shell
git clone https://github.com/ajakhotia/robotFarm.git /tmp/robotFarm-src
git -C /tmp/robotFarm-src submodule update --init
mkdir -p /tmp/robotFarm-install

docker run --rm                                                                                 \
  --volume /tmp/robotFarm-src:/src:ro                                                           \
  --volume /tmp/robotFarm-install:/opt/robotFarm                                                \
  ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest                                          \
  bash -c '
    set -euo pipefail
    cmake -G Ninja -S /src -B /tmp/build                                                        \
        -DCMAKE_BUILD_TYPE=Release                                                              \
        -DCMAKE_TOOLCHAIN_FILE=/src/external/infraCommons/cmake/toolchains/linux-gnu-15.cmake   \
        -DCMAKE_INSTALL_PREFIX=/opt/robotFarm
    apt-get update && apt-get install -y --no-install-recommends                                \
        $(cat /tmp/build/systemDependencies.txt)
    cmake --build /tmp/build
  '
```

The `apt-get install` line inside the container is a no-op when you start from the prebuilt base
image, because the base image already has every build dependency installed. It is kept explicit so
that the same command also works when you start from a plain `ubuntu:24.04` image.

`/tmp/robotFarm-install` is only an example. Replace it with any writable path on the host to choose
where the install-tree ends up.

Before you use the install-tree, be sure to install the system packages the libraries need at
runtime:

```shell
sudo apt update && sudo apt install -y --no-install-recommends \
  $(cat /tmp/robotFarm-install/systemDependencies.txt)
```

For a more permanent setup, write your own Dockerfile that starts with
`FROM ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base` and runs the same steps in a `RUN` layer.

### 🧑‍💻 Build from source

Use the [quickBuild.sh](tools/quickBuild.sh) script to build `robotFarm` on your own machine. It
downloads the source, installs the required dependencies, builds and installs the libraries, and
then cleans up all temporary files. This is a good option if you want to build and install once and
not touch it again.

> [!WARNING] The commands below use `sudo`.

```shell
curl -fsSL                                                                                          \
  https://raw.githubusercontent.com/ajakhotia/robotFarm/refs/heads/main/tools/quickBuild.sh |       \
  sudo bash
```

You can override the version, toolchain, [build list](#selecting-a-subset-of-libraries), and install
prefix:

```shell
curl -fsSL                                                                                          \
  https://raw.githubusercontent.com/ajakhotia/robotFarm/refs/heads/main/tools/quickBuild.sh |       \
  sudo bash -s --                                                                                   \
    --version v2.0.0                                                                                \
    --toolchain linux-clang-22                                                                      \
    --prefix /tmp/robotFarm                                                                         \
    --build-list "GlogExternalProject;GTestExternalProject;FlatBuffersExternalProject"
```

You can see a working example of this in the [nioc](https://github.com/ajakhotia/nioc) project's
[README.md](https://github.com/ajakhotia/nioc/blob/main/README.md#external-dependencies)
and [dockerfile](https://github.com/ajakhotia/nioc/blob/5a7c06a541edee78cc013a007467f1200e44ae46/docker/ubuntu.dockerfile#L83).

## 🐢 Slow Start

The steps below walk through a manual CMake setup for building robotFarm. **They have been tested on
Ubuntu 22.04 and Ubuntu 24.04. See [docker/ubuntu.dockerfile](docker/ubuntu.dockerfile) for a
working example.**

> If you want to pick a specific compiler, linkage mode, or a subset of libraries to build, read
> the [Build Customization](#-build-customization) section before you start.

### 📂 Clone

Pick three paths and make sure you have read and write permission on each one. The rest of this
section refers to them using the tokens below. Replace the tokens with your own values.

| Token          | Purpose                                               | Examples                                                 |
|----------------|-------------------------------------------------------|----------------------------------------------------------|
| `SOURCE_TREE`  | Where robotFarm is cloned. Can be temporary.          | `${HOME}/sandbox/robotFarm`, `/tmp/robotFarm`            |
| `BUILD_TREE`   | Where CMake creates the build-tree. Can be temporary. | `${SOURCE_TREE}/build`, `/tmp/robotFarm-build`           |
| `INSTALL_TREE` | Where the final artifacts are installed. Keep this.   | `${HOME}/opt/robotFarm`, `/opt/robotFarm` (needs `sudo`) |

If you choose an install path that needs root access (for example, `/opt/robotFarm` or `/usr`), you
will need `sudo` for the [Build step](#build-step). When possible, pick a path that your user can
write to.

The commands below use these tokens directly. You can export them as environment variables for
convenience, but this is optional:

```shell
export SOURCE_TREE=${HOME}/sandbox/robotFarm
export BUILD_TREE=${HOME}/sandbox/robotFarm-build
export INSTALL_TREE=${HOME}/opt/robotFarm
```

Clone the repository and initialize its first-level submodules:

```shell
git clone git@github.com:ajakhotia/robotFarm.git ${SOURCE_TREE}
git -C ${SOURCE_TREE} submodule update --init
```

### 🔧 Install tools

**Mandatory** — install `jq`, a recent `cmake` (>= 3.27), and basic build tools:

```shell
sudo apt update &&                                                                            \
sudo apt install -y --no-install-recommends jq                                            &&  \
sudo bash external/infraCommons/tools/installCMake.sh                                     &&  \
sudo apt install -y --no-install-recommends                                                   \
  $(sh external/infraCommons/tools/extractDependencies.sh Basics systemDependencies.json)
```

**Compilers (your choice)** — robotFarm needs C, C++, CUDA, and Fortran compilers on `PATH`. How you
install them is up to you: an apt repository, downloaded tarballs, or any other method that works
for your environment. One option is to run the helper scripts below. They add apt sources for the
latest GNU, LLVM, and NVIDIA releases, and then install the `Compilers` group from
`systemDependencies.json`:

```shell
sudo bash external/infraCommons/tools/apt/addGNUSources.sh    -y &&  \
sudo bash external/infraCommons/tools/apt/addLLVMSources.sh   -y &&  \
sudo bash external/infraCommons/tools/apt/addNvidiaSources.sh -y &&  \
sudo apt update                                                  &&  \
sudo apt install -y --no-install-recommends                          \
  $(sh external/infraCommons/tools/extractDependencies.sh Compilers systemDependencies.json)
```

Run whichever of these scripts you need — all of them, some of them, or none. The minimum supported
CUDA Toolkit version is 13. Each [toolchain file](#pre-packaged-toolchain-files) has its own rules
about which host compiler versions it accepts. If your compiler does not match,
the [Configure step](#configure-step) fails with a clear error message.

### 🧑‍💻 Compile

The compile stage has three steps, each one a single command:
[Configure](#configure-step), [System dependencies](#system-dependencies-step), and
[Build](#build-step).

#### Configure step

This step creates the build-tree and sets the build options (toolchain, install location, and so
on):

```shell
cmake -G Ninja -S ${SOURCE_TREE} -B ${BUILD_TREE}     \
    -DCMAKE_BUILD_TYPE=Release                        \
    -DCMAKE_TOOLCHAIN_FILE=<path-to-toolchain-file>   \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}
```

Replace `<path-to-toolchain-file>` with the toolchain file you want to use. A few ready-to-use ones
come with robotFarm — see [Pre-packaged toolchain files](#pre-packaged-toolchain-files) for the
list.

The [Build Customization](#-build-customization) section shows other ways to run this step: with
a [CMake preset](#cmake-presets),
or [building only a subset of the libraries](#selecting-a-subset-of-libraries).

#### System dependencies step

The [Configure step](#configure-step) writes a list of required system packages into
`${BUILD_TREE}/systemDependencies.txt`. Install them with apt:

```shell
sudo apt install -y --no-install-recommends $(cat ${BUILD_TREE}/systemDependencies.txt)
```

#### Build step

This step builds every external project and installs each one into `${INSTALL_TREE}`:

```shell
cmake --build ${BUILD_TREE}
```

robotFarm is a super-build. The command above runs the build and install steps for every external
project, so no separate `cmake --install` step is needed. If `INSTALL_TREE` points to a path that
needs root access (for example, `/opt/robotFarm` or `/usr`), run the command above with `sudo`.

## 🎛️ Build Customization

### CMake presets

The repository includes a `CMakePresets.json` file. It covers the combinations of toolchain and
linkage used by CI:

- `clang-21-shared`, `clang-21-static`
- `clang-22-shared`, `clang-22-static`
- `gnu-14-shared`,   `gnu-14-static`
- `gnu-15-shared`,   `gnu-15-static`

These presets exist to make CI runs reproducible. They are not required for end users. If one of
them matches your environment, use it in place of the [Configure step](#configure-step) command:

```shell
cmake --preset gnu-15-shared -S ${SOURCE_TREE} -B ${BUILD_TREE} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}
```

The preset sets the generator, toolchain file, build type, and linkage for you. The
`-DCMAKE_INSTALL_PREFIX` line overrides the default install location set in the preset. The
[System dependencies step](#system-dependencies-step) and the [Build step](#build-step) do not
change.

If no preset matches, ignore them — or copy `CMakePresets.json` into your own
`CMakeUserPresets.json` at the repository root and edit it there. `CMakeUserPresets.json` is
gitignored, and CMake merges it with `CMakePresets.json` automatically.

### Pre-packaged toolchain files

A few ready-to-use options are available through the `infraCommons` submodule:

- [linux-clang-21.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-clang-21.cmake)
- [linux-clang-22.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-clang-22.cmake)
- [linux-gnu-14.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-gnu-14.cmake)
- [linux-gnu-15.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-gnu-15.cmake)

After you clone robotFarm, the same files are on your machine at
`${SOURCE_TREE}/external/infraCommons/cmake/toolchains/`. Use the path of the file you pick as the
value of `-DCMAKE_TOOLCHAIN_FILE` in the [Configure step](#configure-step). For example, to use
`linux-gnu-15.cmake`, the configure command becomes:

```shell
cmake -G Ninja -S ${SOURCE_TREE} -B ${BUILD_TREE}                                                   \
    -DCMAKE_BUILD_TYPE=Release                                                                      \
    -DCMAKE_TOOLCHAIN_FILE=${SOURCE_TREE}/external/infraCommons/cmake/toolchains/linux-gnu-15.cmake \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}
```

### Selecting a subset of libraries

By default, robotFarm builds every supported library. To build only a subset, add
`-DROBOT_FARM_REQUESTED_BUILD_LIST` to the [Configure step](#configure-step). For example, to build
only Eigen3 and OpenCV, the configure command becomes:

```shell
cmake -G Ninja -S ${SOURCE_TREE} -B ${BUILD_TREE}                                  \
    -DCMAKE_BUILD_TYPE=Release                                                     \
    -DCMAKE_TOOLCHAIN_FILE=<path-to-toolchain-file>                                \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}                                         \
    -DROBOT_FARM_REQUESTED_BUILD_LIST="Eigen3ExternalProject;OpenCVExternalProject"
```

The allowed values are:

- AbseilExternalProject
- BoostExternalProject
- CapnprotoExternalProject
- CeresSolverExternalProject
- Eigen3ExternalProject
- FlatBuffersExternalProject
- GFlagsExternalProject
- GlogExternalProject
- GoogleTestExternalProject
- NlohmannJsonExternalProject
- OatppExternalProject
- OatppWebSocketExternalProject
- OgreExternalProject
- OpenCVExternalProject
- ProtobufExternalProject
- Python3ExternalProject
- SpdLogExternalProject
- SuiteSparseExternalProject
- VTKExternalProject

## 🧑‍💻 Developer notes

### Python 3

robotFarm can build Python 3 from source if you need it. By default, it uses the system Python 3 and
skips the source build. To build Python 3 from source instead, pass
`-DROBOT_FARM_SKIP_PYTHON3:BOOL=OFF` to CMake in the [Configure step](#configure-step).

### OpenCV

- Building OpenCV with CUDA needs the `opencv_contrib` modules, because the CUDA features depend on
  `cudev`.
- CUDA codecs are not included in CUDA 10.0 or later, so the build turns off the `cudacodec`
  module with `-DBUILD_opencv_cudacodec:BOOL=OFF`.
- The following features are turned off because the required system packages are missing or unclear:
  - OpenGL support
  - GtkGlExt (installing `libgtkglext1` and `libgtkglext1-dev` was not enough)
