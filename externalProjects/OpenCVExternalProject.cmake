#[[ Cmake guard. ]]
if(TARGET OpenCVExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/VTKExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Python3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ProtobufExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GlogExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CeresSolverExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/OgreExternalProject.cmake)

option(ROBOT_FARM_SKIP_OpenCVExternalProject "Forcefully skip OpenCV" OFF)

if(ROBOT_FARM_SKIP_OpenCVExternalProject)
  add_custom_target(OpenCVExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST OpenCVExternalProject)

  option(ROBOT_FARM_OPENCV_WITH_CONTRIB
    "Build OpenCV with the contrib modules (Apache-2 licensed; also the gate for the CUDA modules, which live in contrib)"
    ON)

  option(ROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB
    "Additionally enable the non-free algorithms inside contrib. Please be sure to comply with the licensing"
    OFF)

  set(ROBOT_FARM_OPENCV_CONTRIB_URL
    "https://github.com/opencv/opencv_contrib/archive/refs/tags/5.0.0.tar.gz"
    CACHE STRING
    "URL of the OpenCV contrib source archive")

  set(ROBOT_FARM_OPENCV_URL
    "https://github.com/opencv/opencv/archive/refs/tags/5.0.0.tar.gz"
    CACHE STRING
    "URL of the OpenCV source archive")

  set(ROBOT_FARM_OPENCV_CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}

    #[[ contrib's sfm bundles libmv, which includes <glog/logging.h> through a legacy
        find module instead of the glog::glog target; glog 0.7 refuses such includes
        unless the consumer defines GLOG_USE_GLOG_EXPORT. ]]
    -DCMAKE_CXX_FLAGS:STRING=-DGLOG_USE_GLOG_EXPORT

    -DANDROID_EXAMPLES_WITH_LIBS:BOOL=OFF
    -DBUILD_ANDROID_EXAMPLES:BOOL=OFF
    -DBUILD_ANDROID_PROJECTS:BOOL=OFF
    -DBUILD_ANDROID_SERVICE:BOOL=OFF
    -DBUILD_CUDA_STUBS:BOOL=OFF
    -DBUILD_DOCS:BOOL=OFF
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_FAT_JAVA_LIB:BOOL=OFF
    -DBUILD_IPP_IW:BOOL=ON
    -DBUILD_ITT:BOOL=OFF
    -DBUILD_JASPER:BOOL=OFF
    -DBUILD_JAVA:BOOL=OFF
    -DBUILD_JPEG:BOOL=OFF
    -DBUILD_KOTLIN_EXTENSIONS:BOOL=OFF
    -DBUILD_OBJC:BOOL=OFF
    -DBUILD_opencv_apps:BOOL=OFF
    -DBUILD_opencv_js:BOOL=OFF
    -DBUILD_OPENEXR:BOOL=OFF
    -DBUILD_OPENJPEG:BOOL=OFF
    -DBUILD_PACKAGE:BOOL=OFF
    -DBUILD_PERF_TESTS:BOOL=OFF
    -DBUILD_PNG:BOOL=OFF
    -DBUILD_TBB:BOOL=OFF
    -DBUILD_TESTS:BOOL=OFF
    -DBUILD_TIFF:BOOL=OFF
    -DBUILD_WEBP:BOOL=OFF
    -DBUILD_WITH_DEBUG_INFO:BOOL=OFF
    -DBUILD_WITH_DYNAMIC_IPP:BOOL=OFF
    -DBUILD_WITH_STATIC_CRT:BOOL=OFF
    -DBUILD_ZLIB:BOOL=OFF

    -DCV_DISABLE_OPTIMIZATION:BOOL=OFF
    # SIMD: baseline SSE3 with runtime dispatch up to AVX-512; OFF compiles zero
    # dispatched files and forfeits every vectorized kernel.
    -DCV_ENABLE_INTRINSICS:BOOL=ON
    -DCV_TRACE:BOOL=OFF

    -DENABLE_BUILD_HARDENING:BOOL=OFF
    -DENABLE_CCACHE:BOOL=OFF
    -DENABLE_CONFIG_VERIFICATION:BOOL=OFF
    -DENABLE_COVERAGE:BOOL=OFF
    -DENABLE_CUDA_FIRST_CLASS_LANGUAGE:BOOL=OFF
    -DENABLE_DELAYLOAD:BOOL=OFF
    -DENABLE_FAST_MATH:BOOL=ON
    -DENABLE_FLAKE8:BOOL=OFF
    -DENABLE_GNU_STL_DEBUG:BOOL=OFF
    -DENABLE_IMPL_COLLECTION:BOOL=OFF
    -DENABLE_INSTRUMENTATION:BOOL=OFF
    -DENABLE_LTO:BOOL=OFF
    -DENABLE_NOISY_WARNINGS:BOOL=OFF
    -DENABLE_OMIT_FRAME_POINTER:BOOL=OFF
    -DENABLE_POWERPC:BOOL=OFF
    -DENABLE_PRECOMPILED_HEADERS:BOOL=OFF
    -DENABLE_PROFILING:BOOL=OFF
    -DENABLE_PYLINT:BOOL=OFF
    -DENABLE_SOLUTION_FOLDERS:BOOL=OFF
    -DENABLE_THIN_LTO:BOOL=OFF

    -DGENERATE_ABI_DESCRIPTOR:BOOL=OFF

    -DINSTALL_ANDROID_EXAMPLES:BOOL=OFF
    -DINSTALL_BIN_EXAMPLES:BOOL=OFF
    -DINSTALL_C_EXAMPLES:BOOL=OFF
    -DINSTALL_CREATE_DISTRIB:BOOL=OFF
    -DINSTALL_PYTHON_EXAMPLES:BOOL=OFF
    -DINSTALL_TESTS:BOOL=OFF
    -DINSTALL_TO_MANGLED_PATHS:BOOL=OFF

    -DOBSENSOR_USE_ORBBEC_SDK:BOOL=OFF

    -DOPENCV_DISABLE_ENV_SUPPORT:BOOL=OFF
    -DOPENCV_DISABLE_FILESYSTEM_SUPPORT:BOOL=OFF
    -DOPENCV_DISABLE_THREAD_SUPPORT:BOOL=OFF
    -DOPENCV_ENABLE_MEMALIGN:BOOL=OFF
    -DOPENCV_ENABLE_MEMORY_SANITIZER:BOOL=OFF
    -DOPENCV_GENERATE_PKGCONFIG:BOOL=OFF
    -DOPENCV_GENERATE_SETUPVARS:BOOL=OFF
    -DOPENCV_SEMIHOSTING:BOOL=OFF
    -DOPENCV_WARNINGS_ARE_ERRORS:BOOL=OFF

    -DWITH_1394:BOOL=ON
    -DWITH_ANDROID_MEDIANDK:BOOL=OFF
    -DWITH_ANDROID_NATIVE_CAMERA:BOOL=OFF
    -DWITH_ARAVIS:BOOL=OFF
    -DWITH_AVFOUNDATION:BOOL=OFF
    -DWITH_AVIF:BOOL=ON
    -DWITH_CANN:BOOL=OFF
    -DWITH_CAP_IOS:BOOL=OFF
    -DWITH_CAROTENE:BOOL=OFF
    -DWITH_CLP:BOOL=OFF
    -DWITH_CPUFEATURES:BOOL=OFF
    -DWITH_CUBLAS:BOOL=OFF
    -DWITH_CUDA:BOOL=OFF
    -DWITH_CUDNN:BOOL=OFF
    -DWITH_CUFFT:BOOL=OFF
    -DWITH_DIRECTML:BOOL=OFF
    -DWITH_DIRECTX:BOOL=OFF
    -DWITH_DSHOW:BOOL=OFF
    -DWITH_EIGEN:BOOL=ON
    -DWITH_FASTCV:BOOL=OFF
    -DWITH_FFMPEG:BOOL=ON
    -DWITH_FLATBUFFERS:BOOL=OFF
    -DWITH_FRAMEBUFFER:BOOL=OFF
    -DWITH_FRAMEBUFFER_XVFB:BOOL=OFF
    -DWITH_GDAL:BOOL=ON
    -DWITH_GDCM:BOOL=OFF
    -DWITH_GPHOTO2:BOOL=ON
    -DWITH_GSTREAMER:BOOL=ON
    # highgui takes exactly one GUI backend; Qt6 supersedes GTK3 (overlay, zoom,
    # window persistence) and Qt6 is already a prefix-wide dependency via VTK.
    -DWITH_GTK:BOOL=OFF
    -DWITH_GTK_2_X:BOOL=OFF
    -DWITH_HAL_RVV:BOOL=OFF
    -DWITH_HALIDE:BOOL=OFF
    -DWITH_HPX:BOOL=OFF
    -DWITH_IMGCODEC_GIF:BOOL=ON
    -DWITH_IMGCODEC_HDR:BOOL=ON
    -DWITH_IMGCODEC_PFM:BOOL=ON
    -DWITH_IMGCODEC_PXM:BOOL=ON
    -DWITH_IMGCODEC_SUNRASTER:BOOL=ON
    -DWITH_IPP:BOOL=ON
    -DWITH_ITT:BOOL=OFF
    -DWITH_JASPER:BOOL=OFF
    -DWITH_JPEG:BOOL=ON
    -DWITH_JPEGXL:BOOL=ON
    -DWITH_KLEIDICV:BOOL=OFF
    -DWITH_LAPACK:BOOL=ON
    -DWITH_LIBREALSENSE:BOOL=OFF
    -DWITH_MFX:BOOL=OFF
    -DWITH_MSMF:BOOL=OFF
    -DWITH_MSMF_DXVA:BOOL=OFF
    -DWITH_NDSRVP:BOOL=OFF
    -DWITH_NVCUVENC:BOOL=OFF
    -DWITH_NVCUVID:BOOL=OFF
    -DWITH_OBSENSOR:BOOL=OFF
    -DWITH_ONNX:BOOL=OFF
    -DWITH_OPENCL:BOOL=ON
    -DWITH_OPENCL_D3D11_NV:BOOL=OFF
    -DWITH_OPENCL_SVM:BOOL=OFF
    -DWITH_OPENCLAMDBLAS:BOOL=ON
    -DWITH_OPENCLAMDFFT:BOOL=ON
    -DWITH_OPENEXR:BOOL=ON
    -DWITH_OPENGL:BOOL=ON
    -DWITH_OPENJPEG:BOOL=ON
    -DWITH_OPENMP:BOOL=ON
    -DWITH_OPENNI:BOOL=OFF
    -DWITH_OPENNI2:BOOL=OFF
    -DWITH_OPENVINO:BOOL=OFF
    -DWITH_OPENVX:BOOL=OFF
    -DWITH_PNG:BOOL=ON
    -DWITH_PROTOBUF:BOOL=ON
    -DWITH_PTHREADS_PF:BOOL=OFF
    -DWITH_PVAPI:BOOL=OFF
    -DWITH_QT:BOOL=ON
    -DWITH_QUIRC:BOOL=OFF
    -DWITH_SPNG:BOOL=OFF
    -DWITH_TBB:BOOL=ON
    -DWITH_TIFF:BOOL=ON
    -DWITH_TIMVX:BOOL=OFF
    -DWITH_UEYE:BOOL=OFF
    -DWITH_V4L:BOOL=ON
    -DWITH_VA:BOOL=OFF
    -DWITH_VA_INTEL:BOOL=OFF
    -DWITH_VTK:BOOL=ON
    -DWITH_VULKAN:BOOL=ON
    -DWITH_WAYLAND:BOOL=OFF
    -DWITH_WEBNN:BOOL=OFF
    -DWITH_WEBP:BOOL=ON
    -DWITH_WIN32UI:BOOL=OFF
    -DWITH_XIMEA:BOOL=OFF
    -DWITH_XINE:BOOL=OFF
    -DWITH_ZLIB_NG:BOOL=OFF
  )

  find_package(CUDAToolkit)

  #[[ The CUDA modules live in opencv_contrib (Apache-2, same as the core), so contrib is
      the gate for CUDA rather than the non-free option, which only unlocks the patented
      algorithms inside contrib. ]]
  if(CUDAToolkit_FOUND AND ROBOT_FARM_OPENCV_WITH_CONTRIB)
    message(STATUS "Turning on CUDA options for OpenCV")
    list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
      -DWITH_CUDA:BOOL=ON
      -DWITH_CUBLAS:BOOL=ON
      -DWITH_CUDNN:BOOL=ON
      -DWITH_CUFFT:BOOL=ON
      -DCUDA_FAST_MATH=1
      -DWITH_NVCUVID:BOOL=ON
      -DBUILD_opencv_cudacodec:BOOL=OFF
      -DBUILD_opencv_world:BOOL=OFF)
  else()
    message(STATUS "Turning off CUDA options for OpenCV")
    list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
      -DWITH_CUDA:BOOL=OFF
      -DWITH_CUBLAS:BOOL=OFF
      -DWITH_CUDNN:BOOL=OFF
      -DCUDA_FAST_MATH=0
      -DWITH_NVCUVID:BOOL=OFF
      -DBUILD_opencv_cudacodec:BOOL=OFF
      -DBUILD_opencv_world:BOOL=OFF)
  endif()

  if(ROBOT_FARM_OPENCV_WITH_CONTRIB)
    #[[ The 5.0.0 viz module relies on VTK headers to transitively provide <iostream>,
        which stops holding with VTK 9.6 and GCC 15. Same fix as vcpkg's
        0019-contrib-cout.diff; drop once a release carries it. The patch is valid only
        for the pinned archive, so a user-overridden URL builds unpatched. ]]
    if(ROBOT_FARM_OPENCV_CONTRIB_URL MATCHES "opencv_contrib/archive/refs/tags/5\\.0\\.0\\.tar\\.gz$")
      set(ROBOT_FARM_OPENCV_CONTRIB_PATCH_COMMAND
        PATCH_COMMAND sed -i
          "1i #include <iostream>"
          modules/viz/src/vtk/vtkVizInteractorStyle.cpp
          modules/viz/src/widget.cpp
        COMMAND sed -i
          -e "s|    cout|    std::cout|"
          -e "s|<< endl|<< std::endl|"
          modules/viz/src/vtk/vtkVizInteractorStyle.cpp)
    else()
      set(ROBOT_FARM_OPENCV_CONTRIB_PATCH_COMMAND "")
    endif()

    externalproject_add(OpenCVContribExternalProject
      PREFIX ${CMAKE_CURRENT_BINARY_DIR}/opencv-contrib
      URL ${ROBOT_FARM_OPENCV_CONTRIB_URL}
      DOWNLOAD_NO_PROGRESS ON
      ${ROBOT_FARM_OPENCV_CONTRIB_PATCH_COMMAND}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND "")

    externalproject_get_property(OpenCVContribExternalProject SOURCE_DIR)

    list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
      -DOPENCV_EXTRA_MODULES_PATH:PATH=${SOURCE_DIR}/modules)

    if(ROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB)
      list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
        -DOPENCV_ENABLE_NONFREE:BOOL=ON)
    endif()
  endif()

  externalproject_add(OpenCVExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/opencv
    URL ${ROBOT_FARM_OPENCV_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS ${ROBOT_FARM_OPENCV_CMAKE_ARGS})
endif()

add_dependencies(OpenCVExternalProject
  VTKExternalProject
  Python3ExternalProject
  Eigen3ExternalProject
  ProtobufExternalProject
  GFlagsExternalProject
  GlogExternalProject
  CeresSolverExternalProject
  OgreExternalProject)

if(ROBOT_FARM_OPENCV_WITH_CONTRIB)
  add_dependencies(OpenCVExternalProject OpenCVContribExternalProject)
endif()
