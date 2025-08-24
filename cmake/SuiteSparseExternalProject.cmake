#[[ Cmake guard. ]]
if(TARGET SuiteSparseExternalProject)
  return()
endif()

include(ExternalProject)

option(ROBOT_FARM_SKIP_SuiteSparseExternalProject "Forcefully skip SuiteSparse" OFF)

if(ROBOT_FARM_SKIP_SuiteSparseExternalProject)
  add_custom_target(SuiteSparseExternalProject)
else()
  list(APPEND ROBOT_FARM_BUILD_LIST SuiteSparseExternalProject)

  set(ROBOT_FARM_SUITE_SPARSE_URL
      "https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v7.11.0.tar.gz"
      CACHE STRING
      "URL of the Suite Sparse source archive")

  externalproject_add(SuiteSparseExternalProject
      PREFIX ${CMAKE_CURRENT_BINARY_DIR}/suiteSparse
      URL ${ROBOT_FARM_SUITE_SPARSE_URL}
      DOWNLOAD_NO_PROGRESS ON
      CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE:PATH=${robotFarm_SOURCE_DIR}/cmake/toolchains/linux-gnu-12.cmake
        -DCMAKE_MAKE_PROGRAM:PATH=${CMAKE_MAKE_PROGRAM}
        -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON
        -DCMAKE_EXPORT_PACKAGE_REGISTRY:BOOL=OFF
        -DCMAKE_FIND_USE_PACKAGE_REGISTRY:BOOL=OFF
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_PREFIX_PATH:STRING=${PREFIX_PATH}
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
        -DBUILD_STATIC_LIBS:BOOL=$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>
        -DBUILD_TESTING:BOOL=${BUILD_TESTING}
        -DGRAPHBLAS_BUILD_STATIC_LIBS:BOOL=$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>
        -DGRAPHBLAS_USE_JIT:BOOL=OFF
        -DSPQR_USE_CUDA:BOOL=ON
        -DSUITESPARSE_USE_CUDA:BOOL=ON
        -DSUITESPARSE_USE_OPENMP:BOOL=ON
        -DSUITESPARSE_USE_STRICT:BOOL=ON
        -DSUITESPARSE_CUDA_ARCHITECTURES:STRING=${CMAKE_CUDA_ARCHITECTURES})
endif()
