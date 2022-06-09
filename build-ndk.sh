#!/bin/bash

SDIR=$PWD

export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export ANDROID_USR=$TOOLCHAIN/sysroot/usr
export API=21 # Set this to your minSdkVersion.

rm -rf ./jniLibs; mkdir jniLibs
mkdir build

./bootstrap
# echo "
# #define LIBFAKEROOT_DEBUGGING" >> ./config.h.in

configure_android(){
	export CFLAGS="-I$ANDROID_USR/include" # -fPIE
	export LDFLAGS="-R$ANDROID_USR/lib/$TARGET/$API -L$ANDROID_USR/lib/$TARGET/$API"
	export AR=$TOOLCHAIN/bin/llvm-ar
	export CC=$TOOLCHAIN/bin/$TARGET$API-clang
	export AS=$CC
	export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
	export LD=$TOOLCHAIN/bin/ld
	export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
	export STRIP=$TOOLCHAIN/bin/llvm-strip
	export JNIOUTDIR=$SDIR/jniLibs/$ARCH2
	mkdir $JNIOUTDIR
}

compile_fakeroot(){
	cd $SDIR
	mkdir build/$ARCH2; cd build/$ARCH2
	configure_android
	../../configure --host $TARGET --with-ipc=tcp
	make -j

	cp faked $JNIOUTDIR/libfaked.so
	cp .libs/libfakeroot-0.so $JNIOUTDIR/libfakeroot.so
}

export TARGET=aarch64-linux-android
ARCH2=arm64-v8a
compile_fakeroot

export TARGET=x86_64-linux-android
ARCH2=x86_64
compile_fakeroot

export TARGET=armv7a-linux-androideabi
ARCH2=armeabi-v7a
compile_fakeroot