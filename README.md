[![docker-image](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/docker-image.yaml)

# 🚜 robotFarm

**One command builds the C++ libraries your robotics project needs.**

robotFarm is a CMake super build. You pick the libraries. It downloads their sources, builds them
in dependency order, and installs everything into one prefix. Use it when the apt versions are too
old, when you need CUDA builds, or when every machine on a team should carry the same stack.

> 🐧 **Linux only.** Needs C, C++, Fortran, and CUDA (13 or newer) compilers. Tested on
> Ubuntu 22.04, 24.04, and 26.04. [MIT license](LICENSE).

- **No lock-in**: your project stays a plain `find_package` client. Nothing robotFarm-specific
  enters your CMake:

  ```cmake
  # Configure your project with -DCMAKE_PREFIX_PATH=/opt/robotFarm and use the libraries as usual.
  find_package(OpenCV REQUIRED)
  target_link_libraries(myApp PRIVATE opencv_core opencv_imgproc)
  ```

- **Hands-off**: inter-library build order resolves automatically, and the system packages each
  library needs are computed for you.
- **Auditable**: each library's version and feature flags live in one reviewable recipe under
  [externalProjects/](externalProjects).


## 📚 Supported libraries

<table>
  <tr>
    <td align="center" width="140" height="80"><img src="https://abseil.io/img/absl_204px.png" alt="Abseil" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://www.boost.org/static/img/Boost_Symbol_Transparent.svg" alt="Boost" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://capnproto.org/images/logo.png" alt="Cap'n Proto" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://libeigen.gitlab.io/eigen/docs-nightly/Eigen_Silly_Professor_64x64.png" alt="Eigen" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://flatbuffers.dev/assets/flatbuffers_logo.svg" alt="FlatBuffers" height="48"/></td>
  </tr>
  <tr>
    <td align="center"><sub>Abseil</sub></td>
    <td align="center"><sub>Boost</sub></td>
    <td align="center"><sub>Cap'n Proto</sub></td>
    <td align="center"><sub>Ceres Solver</sub></td>
    <td align="center"><sub>Eigen</sub></td>
    <td align="center"><sub>FlatBuffers</sub></td>
  </tr>
  <tr>
    <td align="center" width="140" height="80"><img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/nlohmann/json/develop/docs/mkdocs/docs/images/json.gif" alt="nlohmann/json" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/lganzzzo/oatpp-website-res/master/logo_x400.png" alt="Oat++" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/OGRECave/ogre/master/Other/ogre_header.svg" alt="OGRE" height="48"/></td>
  </tr>
  <tr>
    <td align="center"><sub>Google Gflags</sub></td>
    <td align="center"><sub>Google Glog</sub></td>
    <td align="center"><sub>Google Test</sub></td>
    <td align="center"><sub>Nlohmann Json</sub></td>
    <td align="center"><sub>Oat++ <sup>*</sup></sub></td>
    <td align="center"><sub>OGRE</sub></td>
  </tr>
  <tr>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/opencv/opencv/4.x/doc/opencv-logo.png" alt="OpenCV" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://www.python.org/static/img/python-logo.png" alt="Python 3" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/gabime/spdlog/v1.x/logos/spdlog.png" alt="spdlog" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://aldenmath.com/wp-content/uploads/bb-plugin/cache/solver-landscape-0b332bbdfde4e320803c1fbef583c3de-.jpg" alt="SuiteSparse" height="48"/></td>
    <td align="center" width="140" height="80"><img src="https://raw.githubusercontent.com/Kitware/VTK/master/vtkBanner.gif" alt="VTK" height="48"/></td>
  </tr>
  <tr>
    <td align="center"><sub>OpenCV</sub></td>
    <td align="center"><sub>Protocol Buffers</sub></td>
    <td align="center"><sub>Python 3</sub></td>
    <td align="center"><sub>Spdlog</sub></td>
    <td align="center"><sub>SuiteSparse <sup>†</sup></sub></td>
    <td align="center"><sub>VTK</sub></td>
  </tr>
</table>

<sub><sup>*</sup> <code>oatpp</code> also bundles <code>oatpp-websocket</code>.</sub>

<sub><sup>†</sup> <code>SuiteSparse</code> bundles <code>AMD</code>, <code>CAMD</code>, <code>
CCOLAMD</code>, <code>CHOLMOD</code>, <code>COLAMD</code>, <code>SPQR</code>, and <code>
SuiteSparse_config</code>.</sub>

Exact versions and feature flags are pinned per recipe in
[externalProjects/](externalProjects). One licensing-sensitive gate to know about: OpenCV's
contrib modules and CUDA features build only with
`-DROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB:BOOL=ON`, which is off by default and off in the
release tarballs.

## ⚡ Quick Start

Three ways in, ordered by effort. Building everything from source takes tens of minutes; the first
two options skip that.


### 📦 Option 1: prebuilt release tarballs

A release is cut by tagging, and each release attaches one install archive per Ubuntu version and
[CMake preset](#cmake-presets) (`gnu-shared`, `gnu-static`, `clang-shared`, `clang-static`; pick
`shared` unless you know you need static). Download yours from the
[releases page](https://github.com/ajakhotia/robotFarm/releases) and extract it under `/opt`:

```shell
tar --zstd -C /opt -xf robotFarm-<os>-<preset>-sha-<commit>.tar.zst
```

The archive ships a `systemDependencies.txt` at its root. It lists the system packages the
libraries need at runtime. Install them:

```shell
sudo apt update && sudo apt install -y --no-install-recommends \
  $(cat /opt/robotFarm/systemDependencies.txt)
```

### 🐳 Option 2: prebuilt base images

CI publishes a build-environment image per Ubuntu version. Compilers, every build dependency, and
a recent `cmake` are preinstalled; robotFarm itself is not:

* `ghcr.io/ajakhotia/robotfarm/ubuntu-22-04/base:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-24-04/base:latest`
* `ghcr.io/ajakhotia/robotfarm/ubuntu-26-04/base:latest`

Replace `latest` with a `sha-<commit>` tag to pin a version. The recipe is
[docker/ubuntu.dockerfile](docker/ubuntu.dockerfile).

Build robotFarm inside a container and keep the install tree on the host:

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
    cmake --build /tmp/build
  '
```

Replace `/tmp/robotFarm-install` with any writable host path. Before using the install tree,
install the runtime packages on the host:

```shell
sudo apt update && sudo apt install -y --no-install-recommends \
  $(cat /tmp/robotFarm-install/systemDependencies.txt)
```

For CI, bake a derived image once: `FROM` the base image, then either run the same build in a
`RUN` layer or extract a release tarball into it. Jobs then start with the stack already in
place.

### 🧑‍💻 Option 3: quickBuild.sh

[quickBuild.sh](tools/quickBuild.sh) builds robotFarm directly on your machine. It clones the
source, registers the apt sources, installs the dependencies, builds, installs, and cleans up
after itself. Good for a build-once machine setup.

> [!WARNING]
> The commands below use `sudo`.

```shell
curl -fsSL                                                                                          \
  https://raw.githubusercontent.com/ajakhotia/robotFarm/refs/heads/main/tools/quickBuild.sh |       \
  sudo bash
```

Version, toolchain, install prefix, and [build list](#selecting-a-subset-of-libraries) are
overridable:

```shell
curl -fsSL                                                                                          \
  https://raw.githubusercontent.com/ajakhotia/robotFarm/refs/heads/main/tools/quickBuild.sh |       \
  sudo bash -s --                                                                                   \
    --version v2.3.1                                                                                \
    --toolchain linux-clang-22                                                                      \
    --prefix /tmp/robotFarm                                                                         \
    --build-list "GlogExternalProject;GoogleTestExternalProject;FlatBuffersExternalProject"
```

[nioc](https://github.com/ajakhotia/nioc) is a real consumer; its
[README](https://github.com/ajakhotia/nioc/blob/main/README.md#-external-dependencies) shows this
in use.

## 🐢 Manual build

The full manual path. Tested on Ubuntu 22.04, 24.04, and 26.04;
[docker/ubuntu.dockerfile](docker/ubuntu.dockerfile) is the working reference.

> To pick a compiler, linkage, or a subset of libraries, read
> [Build Customization](#-build-customization) first.

### 📂 Clone

Pick three writable paths. The commands below refer to them through environment variables:

| Variable       | Purpose                                               | Example                  |
|----------------|-------------------------------------------------------|--------------------------|
| `SOURCE_TREE`  | Where robotFarm is cloned. Temporary is fine.         | `/tmp/robotFarm`         |
| `BUILD_TREE`   | Where CMake builds. Temporary is fine.                | `/tmp/robotFarm-build`   |
| `INSTALL_TREE` | Where the libraries install. Keep this one.           | `${HOME}/opt/robotFarm`  |

An install path that needs root (`/opt`, `/usr`) needs `sudo` on the [Build step](#build-step);
prefer a path your user can write.

```shell
export SOURCE_TREE=/tmp/robotFarm
export BUILD_TREE=/tmp/robotFarm-build
export INSTALL_TREE=${HOME}/opt/robotFarm

git clone https://github.com/ajakhotia/robotFarm.git ${SOURCE_TREE}
git -C ${SOURCE_TREE} submodule update --init
cd ${SOURCE_TREE}
```

### 🔧 Install tools

**Mandatory**: `jq`, a recent `cmake` (3.27 or newer, provided by the `kitware` apt source), and
the basic build tools:

```shell
sudo apt update &&                                                                            \
sudo apt install -y --no-install-recommends                                                   \
  ca-certificates curl gnupg jq software-properties-common                                &&  \
sudo bash external/infraCommons/tools/apt/addAptSources.sh -y kitware                     &&  \
sudo apt update                                                                           &&  \
sudo apt install -y --no-install-recommends                                                   \
  $(sh external/infraCommons/tools/extractDependencies.sh Basics systemDependencies.json)
```

**Compilers**: robotFarm needs C, C++, CUDA, and Fortran compilers on `PATH`. Install them any way
you like. One option is to register the `gnu`, `llvm`, and `nvidia` apt sources and install the
`Compilers` group:

```shell
sudo bash external/infraCommons/tools/apt/addAptSources.sh -y gnu llvm nvidia    &&  \
sudo apt update                                                                  &&  \
sudo apt install -y --no-install-recommends                                          \
  $(sh external/infraCommons/tools/extractDependencies.sh Compilers systemDependencies.json)
```

The minimum supported CUDA Toolkit is 13. Each [toolchain file](#pre-packaged-toolchain-files)
pins absolute compiler paths (`/usr/bin/gcc-15` and so on); the configure fails if a pinned
compiler is not installed.

### 🧑‍💻 Compile

Three steps, one command each.

#### Configure step

Creates the build tree and sets the toolchain and install location:

```shell
cmake -G Ninja -S ${SOURCE_TREE} -B ${BUILD_TREE}     \
    -DCMAKE_BUILD_TYPE=Release                        \
    -DCMAKE_TOOLCHAIN_FILE=<path-to-toolchain-file>   \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}
```

Pick `<path-to-toolchain-file>` from [Pre-packaged toolchain files](#pre-packaged-toolchain-files).

#### System dependencies step

The configure writes the required system packages to `${BUILD_TREE}/systemDependencies.txt`.
Install them:

```shell
sudo apt install -y --no-install-recommends $(cat ${BUILD_TREE}/systemDependencies.txt)
```

#### Build step

Builds and installs every library into `${INSTALL_TREE}`; no separate `cmake --install` is needed:

```shell
cmake --build ${BUILD_TREE}
```

## 🎛️ Build Customization

### CMake presets

[CMakePresets.json](CMakePresets.json) covers the compiler-family and linkage combinations CI
builds: `clang-shared`, `clang-static`, `gnu-shared`, and `gnu-static`. They use the unversioned
system compilers at `/usr/bin/gcc` and `/usr/bin/clang`, through the `linux-gnu.cmake` and
`linux-clang.cmake` toolchain files. If one matches your environment, it replaces the
[Configure step](#configure-step):

```shell
cmake --preset gnu-shared -S ${SOURCE_TREE} -B ${BUILD_TREE} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}
```

If none matches, ignore them, or copy one into a gitignored `CMakeUserPresets.json` and edit it
there.

### Pre-packaged toolchain files

Ready-to-use toolchain files ship in the `infraCommons` submodule at
`${SOURCE_TREE}/external/infraCommons/cmake/toolchains/`:

- [linux-clang.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-clang.cmake)
  and
  [linux-gnu.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-gnu.cmake):
  the default compilers on the system
- [linux-clang-21.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-clang-21.cmake),
  [linux-clang-22.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-clang-22.cmake)
- [linux-gnu-14.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-gnu-14.cmake),
  [linux-gnu-15.cmake](https://github.com/ajakhotia/infraCommons/blob/main/cmake/toolchains/linux-gnu-15.cmake)

Every file probes for CUDA and wires it in when present. Pass your pick as
`-DCMAKE_TOOLCHAIN_FILE` in the [Configure step](#configure-step).

### Selecting a subset of libraries

By default robotFarm builds every supported library. To build a subset, name the projects:

```shell
cmake -G Ninja -S ${SOURCE_TREE} -B ${BUILD_TREE}                                  \
    -DCMAKE_BUILD_TYPE=Release                                                     \
    -DCMAKE_TOOLCHAIN_FILE=<path-to-toolchain-file>                                \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_TREE}                                         \
    -DROBOT_FARM_REQUESTED_BUILD_LIST="Eigen3ExternalProject;OpenCVExternalProject"
```

Dependencies of the requested projects build automatically. The allowed values are:

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

### Declaring your project's robotFarm system packages

A consumer project owns the complete list of system packages it needs, including the packages
required to build its robotFarm subset; nothing is read from robotFarm's generated files when a
consumer builds its images. To derive a `RobotFarmDependencies` group for your project's
`systemDependencies.json`:

1. Expand your requested build list to its transitive closure. Each recipe in
   [`externalProjects/`](externalProjects) `include()`s the recipes it depends on, so follow
   those includes; for example, `Eigen3ExternalProject` pulls in `SuiteSparseExternalProject`.
2. Union the groups named after each project in the closure from robotFarm's own
   [`systemDependencies.json`](systemDependencies.json). A project without a group needs no
   system packages and contributes nothing.

The `systemDependencies.txt` that a configure emits is the same computation performed for the
configured build list, so it makes a convenient cross-check for a hand-derived group.

## 🧑‍💻 Developer notes

### Python 3

robotFarm uses the system Python 3 by default. To build Python 3 from source instead, pass
`-DROBOT_FARM_SKIP_Python3ExternalProject:BOOL=OFF` in the [Configure step](#configure-step).

### OpenCV

- Contrib modules and CUDA features are gated behind
  `-DROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB:BOOL=ON` (off by default): the CUDA features depend
  on `cudev` from contrib, and contrib carries non-free licensing that you must comply with.
- CUDA codecs are absent from CUDA 10.0 and later, so the build turns off `cudacodec`.
- The full flag set is in
  [externalProjects/OpenCVExternalProject.cmake](externalProjects/OpenCVExternalProject.cmake);
  read it before assuming a feature is on.

## 📜 License

[MIT](LICENSE).
