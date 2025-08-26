#[[ Cmake guard. ]]
if(TARGET ProtobufExternalProject)
    return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_ProtobufExternalProject "Forcefully skip Protocol Buffers" OFF)

if(ROBOT_FARM_SKIP_ProtobufExternalProject)
    add_custom_target(ProtobufExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST ProtobufExternalProject)

    set(ROBOT_FARM_PROTOBUF_URL
        "https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protobuf-all-21.5.tar.gz"
        CACHE STRING
        "URL of the Protocol Buffers source archive")

    externalproject_add(ProtobufExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/protobuf
        URL ${ROBOT_FARM_PROTOBUF_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
            ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
            -Dprotobuf_BUILD_TESTS:BOOL=$<BOOL:${BUILD_TESTING}>)
endif()
