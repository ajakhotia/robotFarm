#[[ Cmake guard. ]]
if(TARGET GFlagsExternalProject)
    return()
endif()

include(ExternalProject)

set(ROBOT_FARM_GFLAGS_URL
    "https://github.com/gflags/gflags/archive/refs/tags/v2.2.2.tar.gz"
    CACHE STRING
    "URL of the Google Flags source archive")

externalproject_add(GFlagsExternalProject
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gflags
                    URL ${ROBOT_FARM_GFLAGS_URL}
                    DOWNLOAD_NO_PROGRESS ON
                    CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
                        -DBUILD_STATIC_LIBS:BOOL=ON
                        -DBUILD_gflags_LIB:BOOL=ON
                        -DBUILD_gflags_nothreads_LIB:BOOL=ON
                        -DINSTALL_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
                        -DINSTALL_STATIC_LIBS:BOOL=ON)
