[![infraFilesCongruencyCheck](https://github.com/ajakhotia/robotFarm/actions/workflows/infraFilesCongruencyCheck.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/infraFilesCongruencyCheck.yaml)
[![baseImageBuild](https://github.com/ajakhotia/robotFarm/actions/workflows/baseImageBuild.yaml/badge.svg)](https://github.com/ajakhotia/robotFarm/actions/workflows/baseImageBuild.yaml)
[![External library builds](https://github.com/ajakhotia/robotFarm/actions/workflows/libraryBuild.yaml/badge.svg?branch=main)](https://github.com/ajakhotia/robotFarm/actions/workflows/libraryBuild.yaml)

# robotFarm
A convenience project to build and install certain open source libraries(and listed dependencies)
using cmake external projects. See files under the `cmake` directory to learn about available
options. 

# Usage
Before getting started, come up with paths as listed below. You must have read and write 
permission to each directory you come up with here. Each path here will be denoted using the
following tags throughout the rest of this document. Make replacements in commands appropriately.

### <SOURCE_TREE>
Path where you'd like clone the robotFarm project. This can be a temporary directory if you 
don't plan on iterating on the builds and would like to simply build the libraries once and get 
on with life. Eg: `${HOME}/sandbox/robotFarm` or `/tmp/robotFarm`

### <BUILD_TREE>
Path where you'd like to place the build tree. This too can be a temporary directory if you don't
plan on iterating on the builds and would like to simply build the libraries once and get on with
life. Eg: `<SOURCE_TREE>/build` or `/tmp/robotFarm-build` or `${HOME}/sandbox/robotFarm-build`


### <INSTALL_TREE>
Path where you'd like to place all the installation artifact. This will be the location were all
the executables, libraries, and other supporting files will be installed at. You will want to 
keep this directory around for the long-term. Eg: `${HOME}/usr` or `/opt/robotFarm` or
`/usr`(requires `sudo`)

Now we are all set to get started.

## 1. Download Step
Clone the `robotFarm` project using the following:
```shell
git clone git@github.com:ajakhotia/robotFarm.git <SOURCE_TREE>
```

## 2. Configure Step
Use the command below to configure the build with the default generator for the system:
```shell
cmake \
    -S <SOURCE_TREE> \ 
    -B <BUILD_TREE> \ 
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_TREE>
```
* Alternatively, it's recommended to use `Ninja` as the generator instead of the default for faster
  builds.
  ```shell
  cmake \
      -G Ninja \
      -S <SOURCE_TREE> \ 
      -B <BUILD_TREE> \ 
      -DCMAKE_BUILD_TYPE:STRING="Release" \
      -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_TREE>
  ```
  
## 3. Build Step
You can build a specific subset of libraries available via `robotFarm` using:
```shell
cmake \
    --build <BUILD_TREE> \
    --target <target-name-1> <target-name-2> ... \
    --parallel <num-jobs>
```
* The valid values that can be used for `<target-name-*>` tokens in the above command are the 
  names of the external project targets defined in the files under `cmake` directory. Below is 
  a consolidated list of the same names:
  * BoostExternalProject
  * CapnprotoExternalProject
  * CeresSolverExternalProject
  * Eigen3ExternalProject
  * FlatBuffersExternalProject
  * GFlagsExternalProject
  * GlogExternalProject
  * GoogleTestExternalProject
  * NlohmannJsonExternalProject
  * OatppExternalProject
  * OatppWebsocketExternalProject
  * OgreExternalProject
  * OpenCVExternalProject
  * ProtobufExternalProject
  * Python3ExternalProject
  * SpdLogExternalProject
  * VTKExternalProject
* Replace `<num-jobs>` with the number of virtual cpu cores you'd like to spare for the build.
  Using all cores available on your machine is the fastest way to build but, it may prevent 
  you from performing other tasks during the duration of the build. Plan accordingly.
* Alternatively, you may build all libraries available via `robotFarm` by simply omitting the
  `--target` argument to the build command. CMake assumes to build all targets by default if
  none are provided.
  ```shell
  cmake --build <BUILD_TREE> --parallel <num-jobs>
  ```

## 4. Make Money
Yup!! make money.


# Notes:

## Python3
This project can build python3 from source if needed. However, more often that not, its
more convenient to use the system's version of python3 so the build skips it by default.
* If you'd like to build python3 from source anyway, provide -DROBOT_FARM_SKIP_PYTHON3:BOOL=OFF as
  cache argument to `cmake` at the configure step.
* If you are relying on system's python3 installation, remember to install the following packages:
    * python-dev
    * python3-dev


# Issues:
## Python3
The configure command for python3 has issues with the following flags:
* --with-address-sanitizer
* --with-libs="-lbz2 -lreadline -lncurses -lhistory -lsqlite3 -lssl"

## OpenCV
* Building OpenCV with CUDA requires building with OpenCV-contrib.
    * This is due to a dependency of CUDA based features on cudev.

* Cuda codec are no longer a part of cuda >= 10.0
    * OpenCV build here is forced to use -DBUILD_opencv_cudacodec:BOOL=OFF
    
* The support for following feature is off due to lack of information on the required system
  packages:
    * OpenGL support
    * GtkGlExt
    * Installing libgtkglext1 and libgtkglext1-dev did not help.
