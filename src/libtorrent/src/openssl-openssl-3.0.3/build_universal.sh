#!/bin/sh
mkdir -p arm64
cd arm64
../Configure darwin64-arm64 shared
make clean
make -j8
cd ..
mkdir -p x86_64
cd x86_64
../Configure darwin64-86_64 shared
make clean
make -j8
cd ..
mkdir -p universal
for dylib in arm64/*.dylib; do
  lipo -create -arch arm64 $dylib -arch x86_64 x86_64/$(basename $dylib) -output universal/$(basename $dylib);
done

