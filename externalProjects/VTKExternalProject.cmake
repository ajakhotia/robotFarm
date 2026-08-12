#[[ Cmake guard. ]]
if(TARGET VTKExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_VTKExternalProject "Forcefully skip VTK" OFF)

if(ROBOT_FARM_SKIP_VTKExternalProject)
  add_custom_target(VTKExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST VTKExternalProject)

  set(ROBOT_FARM_VTK_URL
    "https://github.com/Kitware/VTK/archive/refs/tags/v9.6.2.tar.gz"
    CACHE STRING
    "URL of the VTK source archive")

  #[[ The link-based vasprintf probe in VTK's bundled hdf5 passes even where glibc hides the
      declaration, and the strict C compile then rejects the call; forcing the probe negative
      selects hdf5's own fallback implementation. ]]
  externalproject_add(VTKExternalProject
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/vtk
    URL ${ROBOT_FARM_VTK_URL}
    DOWNLOAD_NO_PROGRESS ON
    LIST_SEPARATOR "${ROBOT_FARM_LIST_SEPARATOR}"
    CMAKE_ARGS
    ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
    -DH5_HAVE_VASPRINTF:BOOL=OFF)
endif()
