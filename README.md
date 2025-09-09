[![infra-congruency-check](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml) [![docker-image](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml)

# 🚜 robotFarm

`robotFarm` is a `super-build` setup for commonly used AI and robotics
libraries. It uses `CMake` to build libraries from source, manages inter-library
dependencies, and highlights which prerequisites should be installed through the
OS package manager. Each library is configured to enable the broadest set of
features and optimizations, ensuring reproducible and up-to-date builds.

# 🌱 Why use robotFarm?

* **Up-to-date & flexible**: get the latest stable versions or select specific
  versions via CMake command-line parameters.
* **Efficient**: build once, install to a prefix, reuse across projects.
* **Optimized & consistent**: each library’s config is documented, and builds
  enable maximum features by default for high downstream performance.

# 📚 Supported libraries

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

# Table of contents:

<!-- TOC -->
* [🚜 robotFarm](#-robotfarm)
* [🌱 Why use robotFarm?](#-why-use-robotfarm)
* [📚 Supported libraries](#-supported-libraries)
* [Table of contents:](#table-of-contents)
* [⚡ Quick Start](#-quick-start)
  * [🐳 Prebuilt Docker images](#-prebuilt-docker-images)
  * [🐳🧑‍💻 Build your own Docker image](#-build-your-own-docker-image)
  * [🧑‍💻 Build from source](#-build-from-source)
* [🛠️ Setup](#-setup)
  * [📂 Clone](#-clone)
      * [SOURCE_DIR](#source_dir)
      * [BUILD_DIR](#build_dir)
      * [INSTALL_DIR](#install_dir)
  * [🔧 Install tools](#-install-tools)
  * [🧑‍💻 Compile](#-compile)
    * [⚙️ Configure robotFarm](#-configure-robotfarm)
    * [📦 Install system dependencies](#-install-system-dependencies)
    * [🏭 Build robotFarm](#-build-robotfarm)
* [🧑‍💻 Developer notes:](#-developer-notes)
  * [Python 3](#python-3)
  * [OpenCV](#opencv)
<!-- TOC -->

# ⚡ Quick Start

You can find detailed instructions in the [Setup](#-Setup) section, but here are
a few quick start options for the impatient.

## 🐳 Prebuilt Docker images

Pull the CI-generated Docker image with:

```shell
docker run --rm -it ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/linux-gnu-default/deploy:latest /bin/bash
```

You can find the installation at `/opt/robotFarm`.

Available CI-generated images:

* `ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/linux-gnu-default/deploy:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/linux-gnu-14/deploy:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/linux-clang-19/deploy:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/linux-gnu-default/deploy:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/linux-clang-19/deploy:latest`

Note: These images track the `main` branch. Replace `latest` with a release tag
or commit hash to pin a specific version.

## 🐳🧑‍💻 Build your own Docker image

You can build your own docker image using the following command:

```shell
git clone https://github.com/ajakhotia/robotFarm.git /tmp/robotFarm-src
```

```shell
docker buildx build                                   \
  --tag robotfarm                                     \
  --file /tmp/robotFarm-src/docker/ubuntu.dockerfile  \
  --build-arg OS_BASE=ubuntu:24.04                    \
  --build-arg TOOLCHAIN=linux-gnu-default             \
  /tmp/robotFarm-src
```

## 🧑‍💻 Build from source

```shell
git clone https://github.com/ajakhotia/robotFarm.git /tmp/robotFarm-src
```

```shell
sudo apt install -y jq
```

```shell
sudo apt install -y $(sh /tmp/robotFarm-src/tools/extractDependencies.sh Basics /tmp/robotFarm-src/systemDependencies.json)
```

```shell
sudo bash /tmp/robotFarm-src/tools/installCMake.sh
```

```shell
sudo bash /tmp/robotFarm-src/tools/apt/addGNUSources.sh -y
```

```shell
sudo bash /tmp/robotFarm-src/tools/apt/addLLVMSources.sh -y
```

```shell
sudo bash /tmp/robotFarm-src/tools/apt/addNvidiaSources.sh -y
```

```shell
sudo apt install -y $(sh /tmp/robotFarm-src/tools/extractDependencies.sh Compilers /tmp/robotFarm-src/systemDependencies.json)
```

```shell
cmake -G Ninja                                                                                      \
      -S /tmp/robotFarm-src                                                                         \
      -B /tmp/robotFarm-build                                                                       \
      -DCMAKE_BUILD_TYPE=Release                                                                    \
      -DCMAKE_INSTALL_PREFIX=${HOME}/opt/robotFarm                                                  \
      -DCMAKE_TOOLCHAIN_FILE=/tmp/robotFarm-src/cmake/toolchains/linux-gnu-default.cmake
```

```shell
sudo apt install -y $(cat /tmp/robotFarm-build/systemDependencies.txt)
```

```shell
cmake --build /tmp/robotFarm-build 
```

# 🛠️ Setup

**The following instructions have been tested on Ubuntu 22.04 and Ubuntu 24.04.
Read the docker/ubuntu.dockerfile for details.**

## 📂 Clone

Before getting started, define three paths and ensure you have read and write
permission for each. These paths are referenced throughout the rest of this
document using the following tokens. Substitute your actual paths wherever these
tokens appear.

#### SOURCE_DIR

Path where you will clone the robotFarm project. This may be a temporary
directory if you only plan to build once. Examples:

- `"${HOME}/sandbox/robotFarm"`
- `"/tmp/robotFarm"`

#### BUILD_DIR

Path where you will create the build tree. This may also be temporary if you are
not iterating on builds. Examples:

- `"${SOURCE_DIR}/build"`
- `"/tmp/robotFarm-build"`
- `"${HOME}/sandbox/robotFarm-build"`

#### INSTALL_DIR

Path where installation artifacts will be placed. Keep this directory long-term;
it will contain executables, libraries, and supporting files. Examples:

- `"${HOME}/usr"`
- `"${HOME}/opt"`
- `"/opt/robotFarm"` (requires `sudo` during the build step)
- `"/usr"` (requires `sudo` during the build step)

NOTE: The build step of robotFarm (which is a super-build) triggers the
download, configure, build, and install steps of all the child libraries. Hence,
`sudo` is needed during the build step when installing to a location that
requires superuser privileges to write to. As a general rule prefer to install
to locations that do not require extra privileges.

**NOTE: You may export these paths as environment variables in your current
terminal context if you prefer**

```shell
export SOURCE_TREE=${HOME}/sandbox/robotFarm
export BUILD_TREE=${HOME}/sandbox/robotFarm-build
export INSTALL_TREE=${HOME}/usr
```

Clone the `robotFarm` project using the following:

```shell
git clone git@github.com:ajakhotia/robotFarm.git ${SOURCE_TREE}
```

## 🔧 Install tools

Install `jq` so that we can extract the list of system dependencies from the
[systemDependencies.txt](https://github.com/ajakhotia/robotFarm/blob/main/tools/apt/systemDependencies.json)
file.

```shell
sudo apt install -y --no-install-recommends jq
```

Install `cmake`. You may skip this if your OS-default cmake version is > 3.27

```shell
sudo bash tools/installCMake.sh
```

Install basic build tools:

```shell
sudo apt install -y --no-install-recommends $(sh tools/apt/extractDependencies.sh Basics systemDependencies.json)
```

Set up apt-sources for the latest compilers / toolchains. Prefer to skip this if
the default OS-provided compilers / toolchains are new enough. Note the
following constraints:

* GNU compilers >= version 12
* LLVM compilers >= version 19
* Cuda toolkit >= version 13

You are responsible for installing the appropriate compilers / toolchains
yourself if you are skipping the commands below.

```shell
sudo bash tools/apt/addGNUSources.sh -y
```

```shell
sudo bash tools/apt/addLLVMSources.sh -y
```

```shell
sudo bash tools/apt/addNvidiaSources.sh -y
```

```shell
sudo apt update && sudo apt install -y --no-install-recommends $(sh tools/apt/extractDependencies.sh Compilers systemDependencies.json)
```

## 🧑‍💻 Compile

### ⚙️ Configure robotFarm

Use the following command to configure the build tree. This will set up
robotFarm to build all libraries it is capable of.

```shell
cmake                                                                                         \
    -G Ninja                                                                                  \
    -S ${SOURCE_TREE}                                                                         \ 
    -B ${BUILD_TREE}                                                                          \ 
    -DCMAKE_BUILD_TYPE:STRING="Release"                                                       \
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${SOURCE_TREE}/cmake/toolchains/linux-gnu-default.cmake   \
    -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_TREE}
```

NOTE:

- Using `-G Ninja` is optional but recommended for faster builds.
- Choose the appropriate toolchain file for your needs. Here are some that are
  supported out-of-the-box:
  - linux-clang-19.cmake
  - linux-gnu-14.cmake
  - linux-gnu-default.cmake
- If you want to build only a subset of the available libraries, add the
  following line to the configuration command
  - `-DROBOT_FARM_REQUESTED_BUILD_LIST:STRING=<lib1>;<lib2>;<lib3>;...`
  - where `<lib*>` may assume one of the following values:
    - AbseilExternalProject
    - AtlasExternalProject
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

### 📦 Install system dependencies

The configure command above will generate a file named `systemDependencies.txt`
in the build tree. This file contains a list of system dependencies that are
required to build libraries you requested. Install the dependencies using the
following command:

```shell
sudo apt install -y --no-install-recommends $(cat ${BUILD_TREE}/systemDependencies.txt)
```

### 🏭 Build robotFarm

Use the following command to build and install the requested libraries:

```shell
cmake --build ${BUILD_TREE}
```

* You may need to use `sudo` here if you are installing to a location that
  requires superuser privileges.

# 🧑‍💻 Developer notes:

## Python 3

robotFarm can build Python 3 from source if needed. By default, the build uses
the system Python 3 and skips the source build. To force building Python3 from
source, pass `-DROBOT_FARM_SKIP_PYTHON3:BOOL=OFF` cache argument to cmake in the
configuration step

## OpenCV

- Building OpenCV with CUDA requires opencv_contrib modules because CUDA
  features depend on cudev.
- CUDA codecs are no longer shipped with CUDA >= 10.0, so the build explicitly
  disables the cudacodec module using `-DBUILD_opencv_cudacodec:BOOL=OFF`
- The following features are currently disabled due to missing/uncertain system
  package requirements:
  - OpenGL support
  - GtkGlExt (installing libgtkglext1 and libgtkglext1-dev was not enough)
