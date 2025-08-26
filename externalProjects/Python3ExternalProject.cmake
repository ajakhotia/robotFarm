#[[ CMake guard. ]]
if(TARGET Python3ExternalProject)
    return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_Python3ExternalProject "Forcefully skip Python3" ON)

if(ROBOT_FARM_SKIP_Python3ExternalProject)
    add_custom_target(Python3ExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST Python3ExternalProject)

    set(ROBOT_FARM_PYTHON3_URL
        "https://github.com/python/cpython/archive/refs/tags/v3.10.1.tar.gz"
        CACHE STRING
        "URL of the Python3 source archive")

    externalproject_add(Python3ExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/python3
        URL ${ROBOT_FARM_PYTHON3_URL}
        DOWNLOAD_NO_PROGRESS ON

        CONFIGURE_COMMAND <SOURCE_DIR>/configure
            --prefix=${CMAKE_INSTALL_PREFIX}
            --enable-shared
            --enable-optimizations
            --enable-loadable-sqlite-extensions
            --disable-ipv6
            --enable-big-digits=30
            --with-lto
            --with-system-expat
            --with-system-ffi
            --with-system-libmpdec
            --with-signal-module
            --with-threads
            --with-pymalloc
            --with-fpectl
            --with-computed-gotos
            --with-ensurepip=upgrade)
endif()
