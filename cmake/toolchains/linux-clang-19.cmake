set(CMAKE_HOST_SYSTEM_NAME "Linux")
set(CMAKE_C_COMPILER /usr/bin/clang-19)
set(CMAKE_CXX_COMPILER /usr/bin/clang++-19)

# Older CMake version does not know how to handle flang-new-*.
# Fallback to default gfortran in such cases.
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.27")
  set(CMAKE_Fortran_COMPILER /usr/bin/flang-new-19)
  set(CMAKE_EXE_LINKER_FLAGS "-L/usr/lib/llvm-19/lib -Wl,-rpath,/usr/lib/llvm-19/lib")
else()
  set(CMAKE_Fortran_COMPILER /usr/bin/gfortran)
endif()

set(CMAKE_CUDA_COMPILER /usr/local/cuda-13/bin/nvcc)
set(CMAKE_CUDA_HOST_COMPILER /usr/bin/clang++-19)
set(CMAKE_CUDA_ARCHITECTURES 75;80)
