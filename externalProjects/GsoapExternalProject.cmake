if(TARGET GsoapExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_GsoapExternalProject "Forcefully skip gSOAP" OFF)

if(ROBOT_FARM_SKIP_GsoapExternalProject)
  add_custom_target(GsoapExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST GsoapExternalProject)

  #[[ Pinned to the gSOAP that ArduPilot vendors as its modules/gsoap submodule (2.8.114,
      from ArduPilot's fork, which differs from upstream only by build warning fixes), not to
      gSOAP's latest release: ArduPilot compiles that vendored runtime itself and generates
      its ONVIF bindings with this soapcpp2, and gSOAP refuses to compile when the two
      versions differ. Move this pin together with ArduPilot's submodule pointer. ]]
  set(ROBOT_FARM_GSOAP_URL
    "https://github.com/ArduPilot/gsoap/archive/e1f690585d4803402584962bfaa8240ecaf1db30.tar.gz"
    CACHE STRING
    "URL of the gSOAP source archive")

  # OpenSSL and zlib support are on by default; IPv6 is opt-in. GnuTLS is an alternative to
  # OpenSSL rather than an addition, and IPv6-only mode restricts IPv6, so both stay off.
  externalproject_add(GsoapExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gsoap
    URL ${ROBOT_FARM_GSOAP_URL}
    DOWNLOAD_NO_PROGRESS ON
    BUILD_IN_SOURCE ON
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} -E env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
      <SOURCE_DIR>/configure
      --prefix=${CMAKE_INSTALL_PREFIX}
      --enable-ipv6)
endif()
