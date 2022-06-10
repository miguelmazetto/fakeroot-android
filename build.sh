#!/bin/bash

SDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
RDIR=$SDIR
if [[ ! -z "$MMZ_ROOTFOLDER" ]]; then RDIR=$MMZ_ROOTFOLDER; fi
cd $SDIR

export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export ANDROID_USR=$TOOLCHAIN/sysroot/usr
export API=21 # Set this to your minSdkVersion.

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
	JNIOUTDIR=$RDIR/jniLibs/$ARCH2
	mkdir -p $JNIOUTDIR
}

greencol=$(tput setaf 46)
defaultcol=$(tput sgr0)

compile_fakeroot(){
	mkdir -p $SDIR/build/$ARCH2; cd $SDIR/build/$ARCH2

	printf "\n${greencol}Configuring fakeroot for $TARGET...\n\n${defaultcol}"
	configure_android
	../../configure --host $TARGET --with-ipc=tcp
	
	printf "\n${greencol}Compiling fakeroot for $TARGET...\n\n${defaultcol}"
	make -j

	cp faked $JNIOUTDIR/libfaked.so
	cp .libs/libfakeroot-0.so $JNIOUTDIR/libfakeroot.so
}

rm -rf build
./bootstrap

export TARGET=aarch64-linux-android
ARCH2=arm64-v8a
compile_fakeroot

export TARGET=x86_64-linux-android
ARCH2=x86_64
compile_fakeroot

export TARGET=armv7a-linux-androideabi
ARCH2=armeabi-v7a
compile_fakeroot