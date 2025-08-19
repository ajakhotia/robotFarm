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
        "https://github.com/opencv/opencv_contrib/archive/refs/tags/4.5.5.tar.gz"
        CACHE STRING
        "URL of the OpenCV contrib source archive")

    set(ROBOT_FARM_OPENCV_URL
        "https://github.com/opencv/opencv/archive/refs/tags/4.5.5.tar.gz"
        CACHE STRING
        "URL of the OpenCV source archive")

    set(ROBOT_FARM_OPENCV_CMAKE_ARGS
        ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
        -DWITH_TBB:BOOL=ON
        -DWITH_OPENMP:BOOL=ON
        -DWITH_IPP:BOOL=ON
        -DWITH_VTK:BOOL=ON
        -DWITH_GTK:BOOL=ON
        -DWITH_V4L:BOOL=ON
        -DWITH_QT:BOOL=OFF
        -DWITH_OPENGL:BOOL=ON
        -DWITH_GSTREAMER:BOOL=ON
        -DWITH_CSTRIPES:BOOL=ON
        -DWITH_OPENCL:BOOL=ON
        -DENABLE_FAST_MATH=1)

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

    externalproject_add(OpenCVExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/opencv
        URL ${ROBOT_FARM_OPENCV_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_OPENCV_CMAKE_ARGS})

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
