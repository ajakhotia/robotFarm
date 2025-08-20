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

    option(ROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB
        "Build OpenCV with non-free contrib modules. Please be sure to comply with the licensing"
        OFF)

    set(ROBOT_FARM_OPENCV_CONTRIB_URL
        "https://github.com/opencv/opencv_contrib/archive/refs/tags/4.12.0.tar.gz"
        CACHE STRING
        "URL of the OpenCV contrib source archive")

    set(ROBOT_FARM_OPENCV_URL
        "https://github.com/opencv/opencv/archive/refs/tags/4.12.0.tar.gz"
        CACHE STRING
        "URL of the OpenCV source archive")

    set(ROBOT_FARM_OPENCV_CMAKE_ARGS
        ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}

        #-DANDROID_EXAMPLES_WITH_LIBS:BOOL=ON
        #-DBUILD_ANDROID_EXAMPLES:BOOL=ON
        #-DBUILD_ANDROID_PROJECTS:BOOL=ON
        #-DBUILD_ANDROID_SERVICE:BOOL=ON
        #-DBUILD_CUDA_STUBS:BOOL=ON
        #-DBUILD_DOCS:BOOL=ON
        #-DBUILD_EXAMPLES:BOOL=ON
        #-DBUILD_FAT_JAVA_LIB:BOOL=ON
        #-DBUILD_IPP_IW:BOOL=OFF
        #-DBUILD_ITT:BOOL=OFF
        #-DBUILD_JASPER:BOOL=OFF
        #-DBUILD_JAVA:BOOL=ON
        #-DBUILD_JPEG:BOOL=OFF
        #-DBUILD_KOTLIN_EXTENSIONS:BOOL=ON
        #-DBUILD_OBJC:BOOL=ON
        #-DBUILD_opencv_apps:BOOL=ON
        #-DBUILD_opencv_js:BOOL=ON
        #-DBUILD_OPENEXR:BOOL=OFF
        #-DBUILD_OPENJPEG:BOOL=OFF
        #-DBUILD_PACKAGE:BOOL=ON
        #-DBUILD_PERF_TESTS:BOOL=ON
        #-DBUILD_PNG:BOOL=OFF
        #-DBUILD_SHARED_LIBS:BOOL=ON
        #-DBUILD_TBB:BOOL=OFF
        #-DBUILD_TESTS:BOOL=ON
        #-DBUILD_TIFF:BOOL=OFF
        #-DBUILD_WEBP:BOOL=OFF
        #-DBUILD_WITH_DEBUG_INFO:BOOL=ON
        #-DBUILD_WITH_DYNAMIC_IPP:BOOL=ON
        #-DBUILD_WITH_STATIC_CRT:BOOL=ON
        #-DBUILD_ZLIB:BOOL=OFF

        #-DCV_DISABLE_OPTIMIZATION:BOOL=ON
        #-DCV_ENABLE_INTRINSICS:BOOL=ON
        #-DCV_TRACE:BOOL=ON

        #-DENABLE_BUILD_HARDENING:BOOL=ON
        #-DENABLE_CCACHE:BOOL=ON
        #-DENABLE_CONFIG_VERIFICATION:BOOL=ON
        #-DENABLE_COVERAGE:BOOL=ON
        #-DENABLE_CUDA_FIRST_CLASS_LANGUAGE:BOOL=ON
        #-DENABLE_DELAYLOAD:BOOL=ON
        -DENABLE_FAST_MATH:BOOL=ON
        #-DENABLE_FLAKE8:BOOL=ON
        #-DENABLE_GNU_STL_DEBUG:BOOL=ON
        #-DENABLE_IMPL_COLLECTION:BOOL=ON
        #-DENABLE_INSTRUMENTATION:BOOL=ON
        #-DENABLE_LTO:BOOL=ON
        #-DENABLE_NOISY_WARNINGS:BOOL=ON
        #-DENABLE_OMIT_FRAME_POINTER:BOOL=ON
        #-DENABLE_POWERPC:BOOL=ON
        #-DENABLE_PRECOMPILED_HEADERS:BOOL=ON
        #-DENABLE_PROFILING:BOOL=ON
        #-DENABLE_PYLINT:BOOL=ON
        #-DENABLE_SOLUTION_FOLDERS:BOOL=ON
        #-DENABLE_THIN_LTO:BOOL=ON

        #-DGENERATE_ABI_DESCRIPTOR:BOOL=ON

        #-DINSTALL_ANDROID_EXAMPLES:BOOL=ON
        #-DINSTALL_BIN_EXAMPLES:BOOL=ON
        #-DINSTALL_C_EXAMPLES:BOOL=ON
        #-DINSTALL_CREATE_DISTRIB:BOOL=ON
        #-DINSTALL_PYTHON_EXAMPLES:BOOL=ON
        #-DINSTALL_TESTS:BOOL=ON
        #-DINSTALL_TO_MANGLED_PATHS:BOOL=ON

        #-DOBSENSOR_USE_ORBBEC_SDK:BOOL=ON

        #-DOPENCV_DISABLE_ENV_SUPPORT:BOOL=ON
        #-DOPENCV_DISABLE_FILESYSTEM_SUPPORT:BOOL=ON
        #-DOPENCV_DISABLE_THREAD_SUPPORT:BOOL=ON
        #-DOPENCV_ENABLE_MEMALIGN:BOOL=ON
        #-DOPENCV_ENABLE_MEMORY_SANITIZER:BOOL=ON
        #-DOPENCV_GENERATE_PKGCONFIG:BOOL=ON
        #-DOPENCV_GENERATE_SETUPVARS:BOOL=ON
        #-DOPENCV_SEMIHOSTING:BOOL=ON
        #-DOPENCV_WARNINGS_ARE_ERRORS:BOOL=ON

        #-DWITH_1394:BOOL=ON
        #-DWITH_ANDROID_MEDIANDK:BOOL=ON
        #-DWITH_ANDROID_NATIVE_CAMERA:BOOL=ON
        #-DWITH_ARAVIS:BOOL=ON
        #-DWITH_AVFOUNDATION:BOOL=ON
        #-DWITH_AVIF:BOOL=ON
        #-DWITH_CANN:BOOL=ON
        #-DWITH_CAP_IOS:BOOL=ON
        #-DWITH_CAROTENE:BOOL=ON
        #-DWITH_CLP:BOOL=ON
        #-DWITH_CPUFEATURES:BOOL=ON
        #-DWITH_CUBLAS:BOOL=ON
        #-DWITH_CUDA:BOOL=ON
        #-DWITH_CUDNN:BOOL=ON
        #-DWITH_CUFFT:BOOL=ON
        #-DWITH_DIRECTML:BOOL=ON
        #-DWITH_DIRECTX:BOOL=ON
        #-DWITH_DSHOW:BOOL=ON
        #-DWITH_EIGEN:BOOL=ON
        #-DWITH_FASTCV:BOOL=ON
        #-DWITH_FFMPEG:BOOL=ON
        #-DWITH_FLATBUFFERS:BOOL=ON
        #-DWITH_FRAMEBUFFER:BOOL=ON
        #-DWITH_FRAMEBUFFER_XVFB:BOOL=ON
        #-DWITH_GDAL:BOOL=ON
        #-DWITH_GDCM:BOOL=ON
        #-DWITH_GPHOTO2:BOOL=ON
        -DWITH_GSTREAMER:BOOL=ON
        -DWITH_GTK:BOOL=ON
        -DWITH_GTK_2_X:BOOL=OFF
        #-DWITH_HAL_RVV:BOOL=ON
        #-DWITH_HALIDE:BOOL=ON
        #-DWITH_HPX:BOOL=ON
        #-DWITH_IMGCODEC_GIF:BOOL=ON
        #-DWITH_IMGCODEC_HDR:BOOL=ON
        #-DWITH_IMGCODEC_PFM:BOOL=ON
        #-DWITH_IMGCODEC_PXM:BOOL=ON
        #-DWITH_IMGCODEC_SUNRASTER:BOOL=ON
        -DWITH_IPP:BOOL=ON
        #-DWITH_ITT:BOOL=ON
        #-DWITH_JASPER:BOOL=ON
        #-DWITH_JPEG:BOOL=ON
        #-DWITH_JPEGXL:BOOL=ON
        #-DWITH_KLEIDICV:BOOL=ON
        #-DWITH_LAPACK:BOOL=ON
        #-DWITH_LIBREALSENSE:BOOL=ON
        #-DWITH_MFX:BOOL=ON
        #-DWITH_MSMF:BOOL=ON
        #-DWITH_MSMF_DXVA:BOOL=ON
        #-DWITH_NDSRVP:BOOL=ON
        #-DWITH_NVCUVENC:BOOL=ON
        #-DWITH_NVCUVID:BOOL=ON
        #-DWITH_OBSENSOR:BOOL=ON
        #-DWITH_ONNX:BOOL=ON
        -DWITH_OPENCL:BOOL=ON
        -DWITH_OPENCL_D3D11_NV:BOOL=OFF
        -DWITH_OPENCL_SVM:BOOL=OFF
        -DWITH_OPENCLAMDBLAS:BOOL=ON
        -DWITH_OPENCLAMDFFT:BOOL=ON
        #-DWITH_OPENEXR:BOOL=ON
        -DWITH_OPENGL:BOOL=ON
        #-DWITH_OPENJPEG:BOOL=ON
        -DWITH_OPENMP:BOOL=ON
        #-DWITH_OPENNI2:BOOL=ON
        #-DWITH_OPENNI:BOOL=ON
        #-DWITH_OPENVINO:BOOL=ON
        #-DWITH_OPENVX:BOOL=ON
        #-DWITH_PNG:BOOL=ON
        #-DWITH_PROTOBUF:BOOL=ON
        #-DWITH_PTHREADS_PF:BOOL=ON
        #-DWITH_PVAPI:BOOL=ON
        -DWITH_QT:BOOL=OFF
        #-DWITH_QUIRC:BOOL=ON
        #-DWITH_SPNG:BOOL=ON
        -DWITH_TBB:BOOL=OFF
        #-DWITH_TIFF:BOOL=ON
        #-DWITH_TIMVX:BOOL=ON
        #-DWITH_UEYE:BOOL=ON
        -DWITH_V4L:BOOL=ON
        #-DWITH_VA:BOOL=ON
        #-DWITH_VA_INTEL:BOOL=ON
        -DWITH_VTK:BOOL=ON
        #-DWITH_VULKAN:BOOL=ON
        #-DWITH_WAYLAND:BOOL=ON
        #-DWITH_WEBNN:BOOL=ON
        #-DWITH_WEBP:BOOL=ON
        #-DWITH_WIN32UI:BOOL=ON
        #-DWITH_XIMEA:BOOL=ON
        #-DWITH_XINE:BOOL=ON
        #-DWITH_ZLIB_NG:BOOL=ON
    )

    find_package(CUDAToolkit)

    if(CUDAToolkit_FOUND AND ROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB)
        message(STATUS "Turning on CUDA options for OpenCV")
        list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
            -DWITH_CUDA:BOOL=ON
            -DWITH_CUBLAS:BOOL=ON
            -DCUDA_FAST_MATH=1
            -DWITH_NVCUVID:BOOL=ON
            -DBUILD_opencv_cudacodec:BOOL=OFF
            -DBUILD_opencv_world:BOOL=OFF)
    else()
        message(STATUS "Turning off CUDA options for OpenCV")
        list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
            -DWITH_CUDA:BOOL=OFF
            -DWITH_CUBLAS:BOOL=OFF
            -DCUDA_FAST_MATH=0
            -DWITH_NVCUVID:BOOL=OFF
            -DBUILD_opencv_cudacodec:BOOL=OFF
            -DBUILD_opencv_world:BOOL=OFF)
    endif()

    if(ROBOT_FARM_OPENCV_WITH_NON_FREE_CONTRIB)
        externalproject_add(OpenCVContribExternalProject
            PREFIX ${CMAKE_CURRENT_BINARY_DIR}/opencv-contrib
            URL ${ROBOT_FARM_OPENCV_CONTRIB_URL}
            DOWNLOAD_NO_PROGRESS ON
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND "")

        externalproject_get_property(OpenCVContribExternalProject SOURCE_DIR)

        list(APPEND ROBOT_FARM_OPENCV_CMAKE_ARGS
            -DOPENCV_ENABLE_NONFREE:BOOL=ON
            -DOPENCV_EXTRA_MODULES_PATH:PATH=${SOURCE_DIR}/modules)

        add_dependencies(OpenCVExternalProject OpenCVContribExternalProject)
    endif()

    externalproject_add(OpenCVExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/opencv
        URL ${ROBOT_FARM_OPENCV_URL}
        DOWNLOAD_NO_PROGRESS ON
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
