#!/bin/sh

rm -rf arm64 x86_64 universal stage bin.v2
rm -f b2 project-config*
./bootstrap.sh cxxflags="-arch x86_64 -arch arm64" cflags="-arch x86_64 -arch arm64" linkflags="-arch x86_64 -arch arm64"
./b2 toolset=clang-darwin target-os=darwin architecture=arm abi=aapcs cxxflags="-arch arm64" cflags="-arch arm64" linkflags="-arch arm64" -a threading=multi --layout=tagged
mkdir -p arm64 && mv stage/lib/*.dylib arm64
./b2 toolset=clang-darwin target-os=darwin architecture=x86 cxxflags="-arch x86_64" cflags="-arch x86_64" linkflags="-arch x86_64" abi=sysv binary-format=mach-o -a threading=multi --layout=tagged
mkdir -p x86_64 && mv stage/lib/*.dylib x86_64
mkdir -p universal
for dylib in arm64/*; do 
  lipo -create -arch arm64 $dylib -arch x86_64 x86_64/$(basename $dylib) -output universal/$(basename $dylib); 
done
for dylib in universal/*; do
  lipo $dylib -info;
done
