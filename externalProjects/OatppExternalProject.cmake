if(TARGET OatppExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_OatppExternalProject "Forcefully skip Oatpp" OFF)

if(ROBOT_FARM_SKIP_OatppExternalProject)
  add_custom_target(OatppExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST OatppExternalProject)

  set(ROBOT_FARM_OATPP_URL
    "https://github.com/oatpp/oatpp/archive/refs/tags/1.3.1.tar.gz"
    CACHE STRING
    "URL of the oatpp source archive")

  #[[ oatpp gates its tests behind its own OATPP_BUILD_TESTS (default ON) rather than
      BUILD_TESTING, so the forwarded BUILD_TESTING=OFF alone leaves them building. ]]
  externalproject_add(OatppExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/oatpp
    URL ${ROBOT_FARM_OATPP_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DOATPP_BUILD_TESTS:BOOL=OFF)
endif()
