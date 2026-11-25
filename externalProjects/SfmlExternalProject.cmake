if(TARGET SfmlExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_SfmlExternalProject "Forcefully skip SFML" OFF)

if(ROBOT_FARM_SKIP_SfmlExternalProject)
  add_custom_target(SfmlExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST SfmlExternalProject)

  #[[ Pinned to the latest SFML 2 release rather than SFML 3: ArduPilot's SITL display,
      joystick and audio code uses the SFML 2 API and compiles as C++11, while SFML 3 changed
      that API and requires C++17. Ubuntu 26.04 ships only SFML 3. ]]
  set(ROBOT_FARM_SFML_URL
    "https://github.com/SFML/SFML/archive/refs/tags/2.6.2.tar.gz"
    CACHE STRING
    "URL of the SFML source archive")

  # Every module (system, window, graphics, audio, network) builds by default.
  externalproject_add(SfmlExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/sfml
    URL ${ROBOT_FARM_SFML_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS})
endif()
