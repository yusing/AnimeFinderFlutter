cmake_minimum_required(VERSION 3.0.0)
project(dart_torrent_macos VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-arch x86_64 -arch arm64 -Wall -Wextra -Werror")
set(CMAKE_CXX_FLAGS "-arch x86_64 -arch arm64 -Wall -Wextra -Werror")

find_package(Boost REQUIRED)
include_directories(include/boost_1_79_0)
include_directories(include/libtorrent-rasterbar-2.0.6/include)
add_library(dart_torrent_macos SHARED src/libtorrent.cpp)

file(GLOB BOOST_DYLIBS "include/boost_1_79_0/universal/*.dylib")
target_link_libraries(dart_torrent_macos PRIVATE ${CMAKE_SOURCE_DIR}/lib/libtorrent-rasterbar-2.0.6-macos.dylib)
