#[[ Cmake guard.
if(TARGET AtlasExternalProject)
    return()
endif()

include(ExternalProject)

set(ROBOT_FARM_ATLAS_URL
    "https://sourceforge.net/projects/math-atlas/files/Stable/3.10.3/atlas3.10.3.tar.bz2/download"
    CACHE STRING
    "URL of the Atlas source archive")

set(ROBOT_FARM_ATLAS_NETLIB_LAPACK_URL
    "http://www.netlib.org/lapack/lapack-3.8.0.tar.gz"
    CACHE STRING
    "URL of the Netlib Lapack source archive")

externalproject_add(LapackExternalProject
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/atlas
                    URL ${ROBOT_FARM_ATLAS_NETLIB_LAPACK_URL}
                    DOWNLOAD_NAME lapack.tar.gz
                    DOWNLOAD_NO_PROGRESS ON
                    CONFIGURE_COMMAND ""
                    BUILD_COMMAND ""
                    INSTALL_COMMAND "")

externalproject_add(AtlasExternalProject
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/atlas
                    URL ${ROBOT_FARM_ATLAS_URL}
                    DOWNLOAD_NO_PROGRESS ON

                    CONFIGURE_COMMAND <SOURCE_DIR>/configure
                    -b 64
                    -Si archdef 0
                    -D c -DWALL
                    --shared
                    --prefix=${CMAKE_INSTALL_PREFIX}
                    --with-netlib-lapack-tarfile=<SOURCE_DIR>/../lapack.tar.gz

                    BUILD_COMMAND make
                    COMMAND make check
                    COMMAND make ptcheck
                    COMMAND make time)

add_dependencies(AtlasExternalProject LapackExternalProject) ]]
