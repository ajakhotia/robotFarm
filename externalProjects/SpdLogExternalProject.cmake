#[[ Cmake guard. ]]
if(TARGET SpdLogExternalProject)
    return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_SpdLogExternalProject "Forcefully skip spdlog" OFF)

if(ROBOT_FARM_SKIP_SpdLogExternalProject)
    add_custom_target(SpdLogExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST SpdLogExternalProject)

    set(ROBOT_FARM_SPDLOG_URL
        "https://github.com/gabime/spdlog/archive/refs/tags/v1.9.2.tar.gz"
        CACHE STRING
        "URL of the spdlog source archive")

    externalproject_add(SpdLogExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/spdlog
        URL ${ROBOT_FARM_SPDLOG_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
        ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
        -DSPDLOG_BUILD_SHARED:BOOL=${BUILD_SHARED_LIBS})
endif()
