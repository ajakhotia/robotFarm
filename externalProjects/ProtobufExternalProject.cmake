#[[ Cmake guard. ]]
if(TARGET ProtobufExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/AbseilExternalProject.cmake)

option(ROBOT_FARM_SKIP_ProtobufExternalProject "Forcefully skip Protocol Buffers" OFF)

if(ROBOT_FARM_SKIP_ProtobufExternalProject)
  add_custom_target(ProtobufExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST ProtobufExternalProject)

  set(ROBOT_FARM_PROTOBUF_URL
    "https://github.com/protocolbuffers/protobuf/releases/download/v35.1/protobuf-35.1.tar.gz"
    CACHE STRING
    "URL of the Protocol Buffers source archive")

  externalproject_add(ProtobufExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/protobuf
    URL ${ROBOT_FARM_PROTOBUF_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -Dprotobuf_LOCAL_DEPENDENCIES_ONLY:BOOL=ON
    -Dprotobuf_BUILD_TESTS:BOOL=$<BOOL:${BUILD_TESTING}>)
endif()

add_dependencies(ProtobufExternalProject
  AbseilExternalProject)
