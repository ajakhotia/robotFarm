#[[ Cmake guard. ]]
if(TARGET FlatBuffersExternalProject)
    return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_FlatBuffersExternalProject "Forcefully skip Flat Buffers" OFF)

if(ROBOT_FARM_SKIP_FlatBuffersExternalProject)
    add_custom_target(FlatBuffersExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST FlatBuffersExternalProject)

    set(ROBOT_FARM_FLAT_BUFFERS_URL
        "https://github.com/google/flatbuffers/archive/refs/tags/v25.2.10.tar.gz"
        CACHE STRING
        "URL of the Flat Buffers source archive")

    externalproject_add(FlatBuffersExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/flatbuffers
        URL ${ROBOT_FARM_FLAT_BUFFERS_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
            ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
            -DFLATBUFFERS_BUILD_SHAREDLIB:BOOL=${BUILD_SHARED_LIBS}
            -DFLATBUFFERS_BUILD_TESTS:BOOL=OFF) # Unit tests fail with warnings.
endif()
