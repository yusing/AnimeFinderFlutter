cmake_minimum_required(VERSION 3.0.0)
project(dart_torrent_ios VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -Wextra -Werror")
set(CMAKE_CXX_FLAGS "-arch arm64 -Wall -Wextra -Werror")
set(CMAKE_TOOLCHAIN_FILE ios_toolchain.cmake)

include_directories(${CMAKE_SOURCE_DIR}/src/boost_1_79_0)
include_directories(${CMAKE_SOURCE_DIR}/src/libtorrent-rasterbar-2.0.6/include)
add_library(dart_torrent_ios SHARED ${CMAKE_SOURCE_DIR}/src/libtorrent.cpp)

target_link_libraries(dart_torrent_ios PRIVATE ${CMAKE_SOURCE_DIR}/src/libtorrent-rasterbar-2.0.6/bin/darwin-iphone/release/cxxstd-14-iso/threading-multi/visibility-hidden/libtorrent-rasterbar.dylib.2.0.6)