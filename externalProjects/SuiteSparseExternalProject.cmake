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
        ${ROBOT_FARM_FORWARDED_CMAKE_ARGS}
        -DBUILD_STATIC_LIBS:BOOL=$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>
        -DGRAPHBLAS_BUILD_STATIC_LIBS:BOOL=$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>
        -DGRAPHBLAS_USE_JIT:BOOL=ON
        -DSUITESPARSE_CUDA_ARCHITECTURES:STRING=${CMAKE_CUDA_ARCHITECTURES}
        -DSUITESPARSE_USE_CUDA:BOOL=ON
        -DSUITESPARSE_USE_FORTRAN:BOOL=OFF
        -DSUITESPARSE_USE_OPENMP:BOOL=ON
        -DSUITESPARSE_USE_STRICT:BOOL=ON)
endif()
