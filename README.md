[![infra-congruency-check](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/infra-congruency-check.yaml) [![robot-farm-base](https://github.com/ajakhotia/robotFarm/actions/workflows/robot-farm-base.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/robot-farm-base.yaml) [![robot-farm](https://github.com/ajakhotia/robotFarm/actions/workflows/robot-farm.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/robot-farm.yaml)

# 🚜 robotFarm

`robotFarm` is a CMake-based build system for commonly used robotics and AI
libraries. Package managers often ship stale versions, and some libraries take
too long to rebuild as submodules. `robotFarm` builds and installs the latest
versions with documented, optimized parameters so your projects can reliably
link against them. Refer to the [Build Matrices](#-build-matrices) for available
libraries.

# 🌱 Why use robotFarm?

* **Up-to-date & flexible**: get the latest stable versions or select specific
  versions via CMake command-line parameters.
* **Efficient**: build once, install to a prefix, reuse across projects.
* **Optimized & consistent**: each library’s config is documented, and builds
  enable maximum features by default for reproducible performance.

# 🏗️ Build status

| Library            | ubuntu:22.04 / linux-gnu-12                                                                                                                                                                                                                                     | ubuntu:22.04 / linux-clang-19                                                                                                                                                                                                                                       | ubuntu:22.04 / linux-gnu-default                                                                                                                                                                                                                                          |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| absl               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-gnu-12.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-22-04-linux-gnu-default.yaml)                             |
| AMD                | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-gnu-12.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-clang-19.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-22-04-linux-gnu-default.yaml)                               |
| Boost              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-gnu-12.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-22-04-linux-gnu-default.yaml)                           |
| CAMD               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-gnu-12.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-22-04-linux-gnu-default.yaml)                             |
| CapnProto          | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-gnu-12.yaml)                   | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-clang-19.yaml)                   | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-22-04-linux-gnu-default.yaml)                   |
| CCOLAMD            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-gnu-12.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-22-04-linux-gnu-default.yaml)                       |
| Ceres              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-gnu-12.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-22-04-linux-gnu-default.yaml)                           |
| CHOLMOD            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-gnu-12.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-22-04-linux-gnu-default.yaml)                       |
| COLAMD             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-gnu-12.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-22-04-linux-gnu-default.yaml)                         |
| Eigen3             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-gnu-12.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-22-04-linux-gnu-default.yaml)                         |
| flatbuffers        | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-gnu-12.yaml)               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-clang-19.yaml)               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-22-04-linux-gnu-default.yaml)               |
| Gflags             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-gnu-12.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-22-04-linux-gnu-default.yaml)                         |
| Glog               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-gnu-12.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-22-04-linux-gnu-default.yaml)                             |
| GTest              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-gnu-12.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-22-04-linux-gnu-default.yaml)                           |
| nlohmann_json      | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-gnu-12.yaml)           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-clang-19.yaml)           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-22-04-linux-gnu-default.yaml)           |
| oatpp              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-gnu-12.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-22-04-linux-gnu-default.yaml)                           |
| oatpp-websocket    | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-gnu-12.yaml)       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-clang-19.yaml)       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-22-04-linux-gnu-default.yaml)       |
| OGRE               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-gnu-12.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-22-04-linux-gnu-default.yaml)                             |
| OpenCV             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-gnu-12.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-22-04-linux-gnu-default.yaml)                         |
| protobuf           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-gnu-12.yaml)                     | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-clang-19.yaml)                     | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-22-04-linux-gnu-default.yaml)                     |
| Python3            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-gnu-12.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-22-04-linux-gnu-default.yaml)                       |
| spdlog             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-gnu-12.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-22-04-linux-gnu-default.yaml)                         |
| SPQR               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-gnu-12.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-22-04-linux-gnu-default.yaml)                             |
| SuiteSparse_config | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-gnu-12.yaml) | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-clang-19.yaml) | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-22-04-linux-gnu-default.yaml) |
| VTK                | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-gnu-12.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-gnu-12.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-clang-19.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-22-04-linux-gnu-default.yaml)                               |

| Library            | ubuntu:24.04 / linux-gnu-14                                                                                                                                                                                                                                     | ubuntu:24.04 / linux-clang-19                                                                                                                                                                                                                                       | ubuntu:24.04 / linux-gnu-default                                                                                                                                                                                                                                          |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| absl               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-gnu-14.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-absl-ubuntu-24-04-linux-gnu-default.yaml)                             |
| AMD                | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-gnu-14.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-clang-19.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-AMD-ubuntu-24-04-linux-gnu-default.yaml)                               |
| Boost              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-gnu-14.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Boost-ubuntu-24-04-linux-gnu-default.yaml)                           |
| CAMD               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-gnu-14.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CAMD-ubuntu-24-04-linux-gnu-default.yaml)                             |
| CapnProto          | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-gnu-14.yaml)                   | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-clang-19.yaml)                   | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CapnProto-ubuntu-24-04-linux-gnu-default.yaml)                   |
| CCOLAMD            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-gnu-14.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CCOLAMD-ubuntu-24-04-linux-gnu-default.yaml)                       |
| Ceres              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-gnu-14.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Ceres-ubuntu-24-04-linux-gnu-default.yaml)                           |
| CHOLMOD            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-gnu-14.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-CHOLMOD-ubuntu-24-04-linux-gnu-default.yaml)                       |
| COLAMD             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-gnu-14.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-COLAMD-ubuntu-24-04-linux-gnu-default.yaml)                         |
| Eigen3             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-gnu-14.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Eigen3-ubuntu-24-04-linux-gnu-default.yaml)                         |
| flatbuffers        | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-gnu-14.yaml)               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-clang-19.yaml)               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-flatbuffers-ubuntu-24-04-linux-gnu-default.yaml)               |
| Gflags             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-gnu-14.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Gflags-ubuntu-24-04-linux-gnu-default.yaml)                         |
| Glog               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-gnu-14.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Glog-ubuntu-24-04-linux-gnu-default.yaml)                             |
| GTest              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-gnu-14.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-GTest-ubuntu-24-04-linux-gnu-default.yaml)                           |
| nlohmann_json      | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-gnu-14.yaml)           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-clang-19.yaml)           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-nlohmann_json-ubuntu-24-04-linux-gnu-default.yaml)           |
| oatpp              | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-gnu-14.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-clang-19.yaml)                           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-ubuntu-24-04-linux-gnu-default.yaml)                           |
| oatpp-websocket    | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-gnu-14.yaml)       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-clang-19.yaml)       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-oatpp-websocket-ubuntu-24-04-linux-gnu-default.yaml)       |
| OGRE               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-gnu-14.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OGRE-ubuntu-24-04-linux-gnu-default.yaml)                             |
| OpenCV             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-gnu-14.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-OpenCV-ubuntu-24-04-linux-gnu-default.yaml)                         |
| protobuf           | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-gnu-14.yaml)                     | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-clang-19.yaml)                     | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-protobuf-ubuntu-24-04-linux-gnu-default.yaml)                     |
| Python3            | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-gnu-14.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-clang-19.yaml)                       | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-Python3-ubuntu-24-04-linux-gnu-default.yaml)                       |
| spdlog             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-gnu-14.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-clang-19.yaml)                         | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-spdlog-ubuntu-24-04-linux-gnu-default.yaml)                         |
| SPQR               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-gnu-14.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-clang-19.yaml)                             | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SPQR-ubuntu-24-04-linux-gnu-default.yaml)                             |
| SuiteSparse_config | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-gnu-14.yaml) | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-clang-19.yaml) | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-SuiteSparse_config-ubuntu-24-04-linux-gnu-default.yaml) |
| VTK                | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-gnu-14.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-gnu-14.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-clang-19.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-clang-19.yaml)                               | [![status](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-gnu-default.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/validate-VTK-ubuntu-24-04-linux-gnu-default.yaml)                               |

# 🛠️ Setup

**The following instructions have been tested on Ubuntu 22.04 and Ubuntu 24.04.
Read the docker/robotFarm-ubuntu.dockerfile for details.**

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

## 📂 Clone and Compile

Before getting started, define three paths and ensure you have read and write
permission for each. These paths are referenced throughout the rest of this
document using the following tokens. Substitute your actual paths wherever these
tokens appear.

#### SOURCE_DIR

Path where you will clone the robotFarm project. This may be a temporary
directory if you only plan to build once. Examples:

- `"$HOME/sandbox/robotFarm"`
- `"/tmp/robotFarm"`

#### BUILD_DIR

Path where you will create the build tree. This may also be temporary if you are
not iterating on builds. Examples:

- `"${SOURCE_DIR}/build"`
- `"/tmp/robotFarm-build"`
- `"$HOME/sandbox/robotFarm-build"`

#### INSTALL_DIR

Path where installation artifacts will be placed. Keep this directory long-term;
it will contain executables, libraries, and supporting files. Examples:

- `"$HOME/usr"`
- `"/opt/robotFarm"`
- `"/usr"` (requires `sudo` during the installation step)

**NOTE: You may export these paths as environment variables in your current
terminal context if you prefer**

```shell
export SOURCE_TREE=$HOME/sandbox/robotFarm
export BUILD_TREE=$HOME/sandbox/robotFarm-build
export INSTALL_TREE=$HOME/usr
```

### 🧬 Clone robotFarm

Clone the `robotFarm` project using the following:

```shell
git clone git@github.com:ajakhotia/robotFarm.git ${SOURCE_TREE}
```

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

- Using `-G Ninja` is optional but recommended faster builds.
- Choose the appropriate toolchain file for your needs.
- If you want to build only a subset of the available libraries, add the
  following line to the configuration command
  - `-DROBOT_FARM_REQUESTED_BUILD_LIST:STRING=<lib1>;<lib2>;<lib3>;...`
  - where `<lib*>` assume one of the following values:
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

The configure command above will generate a file called `systemDependencies.txt`
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

You can build a specific subset of libraries available via `robotFarm` using:

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
source, pass `-DROBOT_FARM_SKIP_PYTHON3:BOOL=OFF` cache argument to cmake in
the configuration step

## OpenCV

- Building OpenCV with CUDA requires opencv_contrib modules because CUDA
  features depend on cudev.
- CUDA codecs are no longer shipped with CUDA >= 10.0, so the build explicitly
  disables the cudacodec module using `-DBUILD_opencv_cudacodec:BOOL=OFF`
- The following features are currently disabled due to missing/uncertain system
  package requirements:
  - OpenGL support
  - GtkGlExt (installing libgtkglext1 and libgtkglext1-dev was not enough)
