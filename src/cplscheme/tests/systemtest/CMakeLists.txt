cmake_minimum_required(VERSION 3.9)
project(SolverdummyCPP LANGUAGES CXX DESCRIPTION "preCICE CPP solver dummy")

find_package(precice REQUIRED CONFIG)
find_package(MPI REQUIRED)

add_executable(dummy_serial dummy_serial.cpp)
set_target_properties(dummy_serial PROPERTIES CXX_STANDARD 11)
target_link_libraries(dummy_serial PRIVATE precice::precice)

add_executable(dummy_parallel dummy_parallel.cpp)
set_target_properties(dummy_parallel PROPERTIES CXX_STANDARD 11)
target_link_libraries(dummy_parallel PRIVATE precice::precice MPI::MPI_CXX)
