set(CMAKE_HOST_SYSTEM_NAME "Linux")
set(CMAKE_C_COMPILER /usr/bin/gcc)
set(CMAKE_CXX_COMPILER /usr/bin/g++)
set(CMAKE_Fortran_COMPILER /usr/bin/gfortran)

execute_process(
    COMMAND ${CMAKE_C_COMPILER} -dumpversion
    OUTPUT_VARIABLE GCC_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(GCC_VERSION VERSION_LESS "13")
  message(STATUS "Detected default GNU as ${GCC_VERSION} < 13 — forcing gcc-13, g++-13, and gfortran-13")
  set(CMAKE_C_COMPILER /usr/bin/gcc-13)
  set(CMAKE_CXX_COMPILER /usr/bin/g++-13)
  set(CMAKE_Fortran_COMPILER /usr/bin/gfortran-13)
endif()

set(CMAKE_CUDA_COMPILER /usr/local/cuda-13/bin/nvcc)
set(CMAKE_CUDA_HOST_COMPILER ${CMAKE_CXX_COMPILER})
set(CMAKE_CUDA_ARCHITECTURES 75;80)
