#[[ Cmake guard. ]]
if(TARGET GoogleTestExternalProject)
    return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_GoogleTestExternalProject "Forcefully skip Google Test" OFF)

if(ROBOT_FARM_SKIP_GoogleTestExternalProject)
    add_custom_target(GoogleTestExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST GoogleTestExternalProject)

    set(ROBOT_FARM_GOOGLE_TEST_URL
        "https://github.com/google/googletest/archive/refs/tags/release-1.11.0.tar.gz"
        CACHE STRING
        "URL of the Google Test source archive")

    externalproject_add(GoogleTestExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googleTest
        URL ${ROBOT_FARM_GOOGLE_TEST_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()
