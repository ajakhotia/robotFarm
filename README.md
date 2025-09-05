[![infra-congruency-check](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml) [![docker-image](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml)


# 🚜 robotFarm

`robotFarm` is a `super-build` setup for commonly used AI and robotics 
libraries. It
uses `CMake` to build libraries from source, manages inter-library dependencies,
and highlights which prerequisites should be installed through the OS package
manager. Each library is configured to enable the broadest set of features and
optimizations, ensuring reproducible and up-to-date builds.

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
- `"/opt/robotFarm"`
- `"/usr"` (requires `sudo` during the installation step)

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
sudo apt-get install -y --no-install-recommends jq
```

Install `cmake`. You may skip this if your OS-default cmake version is > 3.27

```shell
sudo bash tools/installCMake.sh
```

Install basic build tools:

```shell
sudo apt-get install -y --no-install-recommends $(sh tools/apt/extractDependencies.sh Basics)
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
sudo bash tools/apt/addLLVMSources.sh -y
sudo bash tools/apt/addNvidiaSources.sh -y
sudo apt-get update && apt-get install -y --no-install-recommends $(sh tools/apt/extractDependencies.sh Compilers)
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
sudo apt-get install -y --no-install-recommends $(cat ${BUILD_TREE}/systemDependencies.txt)
```

### 🏭 Build robotFarm

Use the following command to build and install the requested libraries:

```shell
cmake --build ${BUILD_TREE}
```

# 🧑‍💻 Developer notes:

## Generate validation workflows for GitHub.

#### Ubuntu:22.04

```shell
python3 ./.github/workflows/generate_library_validation_workflows.py \
     --library absl,AMD,Boost,CAMD,CapnProto,CCOLAMD,Ceres,CHOLMOD,COLAMD,Eigen3,flatbuffers,Gflags,Glog,GTest,nlohmann_json,oatpp,oatpp-websocket,OGRE,OpenCV,protobuf,Python3,spdlog,SPQR,SuiteSparse_config,VTK \
     --os-base ubuntu:22.04 \
     --toolchain linux-gnu-12,linux-clang-19,linux-gnu-default
```

#### Ubuntu:24.04

```shell
python3 ./.github/workflows/generate_library_validation_workflows.py \
     --library absl,AMD,Boost,CAMD,CapnProto,CCOLAMD,Ceres,CHOLMOD,COLAMD,Eigen3,flatbuffers,Gflags,Glog,GTest,nlohmann_json,oatpp,oatpp-websocket,OGRE,OpenCV,protobuf,Python3,spdlog,SPQR,SuiteSparse_config,VTK \
     --os-base ubuntu:24.04 \
     --toolchain linux-gnu-14,linux-clang-19,linux-gnu-default
```

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
