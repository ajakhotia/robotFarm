if(TARGET ArduPilotExternalProject)
  return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/GsoapExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SfmlExternalProject.cmake)

option(ROBOT_FARM_SKIP_ArduPilotExternalProject "Forcefully skip ArduPilot" OFF)

if(ROBOT_FARM_SKIP_ArduPilotExternalProject)
  add_custom_target(ArduPilotExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST ArduPilotExternalProject)

  set(ROBOT_FARM_ARDUPILOT_URL
    "https://github.com/ArduPilot/ardupilot.git"
    CACHE STRING
    "URL of the ArduPilot git repository")

  # ArduPilot tags each vehicle's release separately; the 4.7.3 tags of every vehicle
  # (Copter, Plane, Rover, Sub, Tracker) name this same commit.
  set(ROBOT_FARM_ARDUPILOT_TAG
    "Copter-4.7.3"
    CACHE STRING
    "Git tag of the ArduPilot release")

  #[[ ArduPilot builds with waf, not CMake, so the forwarded cache arguments do not apply;
      the compilers are handed to waf through the environment instead. Only the SITL board
      is built: it compiles every vehicle (copter, heli, plane, rover, sub, blimp, antenna
      tracker) into a host executable that drives a simulator. Firmware for flight
      controller boards needs an ARM cross toolchain and is out of scope here. The clone
      fetches every submodule recursively, as upstream documents: the build compiles
      sources straight out of several of them and does not fetch them itself. Every
      optional SITL feature is enabled except DDS, which needs the Micro-XRCE-DDS-Gen code
      generator. ONVIF compiles the gSOAP runtime vendored in modules/gsoap and generates its
      bindings with the soapcpp2 that GsoapExternalProject pins to the same version. ]]

  #[[ The SITL display, joystick, audio, OSD and RGB LED features need SFML 2, found in the
      install prefix through the preprocessor and linker flags waf reads from the
      environment. waf links SFML by its plain shared library names without SFML's own
      dependencies, so it cannot consume the static archives a static build produces; static
      builds leave these features out. ]]
  set(ARDUPILOT_SFML_OPTIONS "")
  if(BUILD_SHARED_LIBS)
    set(ARDUPILOT_SFML_OPTIONS
      --enable-sfml
      --enable-sfml-audio
      --enable-sfml-joystick
      --sitl-osd
      --sitl-rgbled)
  endif()

  externalproject_add(ArduPilotExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ardupilot
    GIT_REPOSITORY ${ROBOT_FARM_ARDUPILOT_URL}
    GIT_TAG ${ROBOT_FARM_ARDUPILOT_TAG}
    GIT_SHALLOW TRUE
    GIT_SUBMODULES_RECURSE TRUE
    DOWNLOAD_NO_PROGRESS ON
    BUILD_IN_SOURCE ON
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} -E env
        CC=${CMAKE_C_COMPILER}
        CXX=${CMAKE_CXX_COMPILER}
        SOAPCPP2=${CMAKE_INSTALL_PREFIX}/bin/soapcpp2
        "CPPFLAGS=-isystem ${CMAKE_INSTALL_PREFIX}/include"
        "LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib -Wl,-rpath,$ORIGIN/../lib"
      ./waf configure
      --board sitl
      --prefix ${CMAKE_INSTALL_PREFIX}
      --enable-custom-controller
      --enable-gps-logging
      --enable-lttng
      --enable-onvif
      --enable-opendroneid
      --enable-scripting
      ${ARDUPILOT_SFML_OPTIONS}
    BUILD_COMMAND ./waf build
    INSTALL_COMMAND ./waf install)
endif()

add_dependencies(ArduPilotExternalProject
  GsoapExternalProject
  SfmlExternalProject)
