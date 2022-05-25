cmake_minimum_required(VERSION 3.0.0)
project(libtorrent_simple_c_test VERSION 0.1.0)

set(CMAKE_C_STANDARD 11)

include_directories(${CMAKE_SOURCE_DIR}/include/)
add_executable(libtorrent_simple_c_test ${CMAKE_CURRENT_LIST_DIR}/simple_test.c)
target_link_libraries(libtorrent_simple_c_test ${CMAKE_SOURCE_DIR}/build/libtorrent.dylib)