#[[ Cmake guard. ]]
if(TARGET CeresSolverExternalProject)
    return()
endif()

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/AbseilExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Eigen3ExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GFlagsExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/GlogExternalProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/SuiteSparseExternalProject.cmake)

option(ROBOT_FARM_SKIP_CeresSolverExternalProject "Forcefully skip Ceres Solver" OFF)

set(OMP_FLAG_C   "")
set(OMP_FLAG_CXX "")
set(OMP_LINK     "")

if(CMAKE_C_COMPILER_ID MATCHES "AppleClang" OR CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    set(OMP_FLAG_C   "-Xpreprocessor -fopenmp")
    set(OMP_FLAG_CXX "-Xpreprocessor -fopenmp")
    set(OMP_LINK     "-lomp")
elseif(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(OMP_FLAG_C   "-fopenmp")
    set(OMP_FLAG_CXX "-fopenmp")
    set(OMP_LINK     "-fopenmp")
else()
    message(WARNING "Unknown compiler family; not adding OpenMP flags for Ceres external build.")
endif()

if(ROBOT_FARM_SKIP_CeresSolverExternalProject)
    add_custom_target(CeresSolverExternalProject)
else()
    list(APPEND ROBOT_FARM_BUILD_LIST CeresSolverExternalProject)

    set(ROBOT_FARM_CERES_SOLVER_URL
        "https://github.com/ceres-solver/ceres-solver.git"
        CACHE STRING
        "URL of the Ceres Solver source archive")

    externalproject_add(CeresSolverExternalProject
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ceressolver
        GIT_REPOSITORY ${ROBOT_FARM_CERES_SOLVER_URL}
        GIT_SHALLOW TRUE
        DOWNLOAD_NO_PROGRESS ON
        CMAKE_ARGS
          ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
          -DCMAKE_C_FLAGS=${OMP_FLAG_C}
          -DCMAKE_CXX_FLAGS=${OMP_FLAG_CXX}
          -DCMAKE_EXE_LINKER_FLAGS=${OMP_LINK}
          -DCMAKE_SHARED_LINKER_FLAGS=${OMP_LINK})
endif()

add_dependencies(CeresSolverExternalProject
    AbseilExternalProject
    Eigen3ExternalProject
    GFlagsExternalProject
    GlogExternalProject
    SuiteSparseExternalProject)
