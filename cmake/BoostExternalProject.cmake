#[[ CMake guard. ]]
if(TARGET BoostExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/Python3ExternalProject.cmake)

option(ROBOT_FARM_SKIP_BoostExternalProject "Forcefully skip Boost" OFF)

if(ROBOT_FARM_SKIP_BoostExternalProject)
    add_custom_target(BoostExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST BoostExternalProject)

    set(ROBOT_FARM_BOOST_URL
        "https://github.com/boostorg/boost/releases/download/boost-1.89.0/boost-1.89.0-b2-nodocs.tar.gz"
        CACHE STRING "URL of the Boost source archive")

    # See: https://www.boost.org/doc/libs/1_78_0/more/getting_started/unix-variants.html#identify-your-toolset
    set(ROBOT_FARM_BOOST_TOOLSET gcc CACHE
        STRING "Toolset name to use for building boost[Default: gcc]")

    set(BOOST_LINK_TYPE static)
    if(BUILD_SHARED_LIBS)
        set(BOOST_LINK_TYPE shared)
    endif()

    set(BOOST_VARIANT_TYPE release)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(BOOST_VARIANT_TYPE debug)
    endif()

    externalproject_add(BoostExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/boost
        URL ${ROBOT_FARM_BOOST_URL}
        DOWNLOAD_NO_PROGRESS ON

        CONFIGURE_COMMAND
            LD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:$ENV{LD_LIBRARY_PATH}
            PATH=${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}
            <SOURCE_DIR>/bootstrap.sh
                --prefix=${CMAKE_INSTALL_PREFIX}
                --with-libraries=all
                --with-python-root=${CMAKE_INSTALL_PREFIX}
                --with-python=python3
                --with-toolset=${ROBOT_FARM_BOOST_TOOLSET}

        BUILD_COMMAND
            <SOURCE_DIR>/b2
                --build-type=complete
                --layout=tagged
                install
                link=${BOOST_LINK_TYPE}
                runtime-link=${BOOST_LINK_TYPE}
                threading=multi
                variant=${BOOST_VARIANT_TYPE}

        BUILD_IN_SOURCE ON
        INSTALL_COMMAND "")
endif()

add_dependencies(BoostExternalProject Python3ExternalProject)
