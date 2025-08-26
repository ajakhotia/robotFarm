#[[ Cmake guard. ]]
if(TARGET AbseilExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GoogleTestExternalProject.cmake)


option(ROBOT_FARM_SKIP_AbseilExternalProject "Forcefully skip Abseil" OFF)

if(ROBOT_FARM_SKIP_AbseilExternalProject)
    add_custom_target(AbseilExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST AbseilExternalProject)

    set(ROBOT_FARM_ABSEIL_URL
        "https://github.com/abseil/abseil-cpp/archive/refs/tags/20250814.0.tar.gz"
        CACHE STRING
        "URL of the Abseil source archive")

    externalproject_add(AbseilExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/abseil
        URL ${ROBOT_FARM_ABSEIL_URL}
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
          ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
          -DABSL_FIND_GOOGLETEST:BOOL=ON)
endif()

add_dependencies(AbseilExternalProject
    GoogleTestExternalProject)
