#!/usr/bin/env bash
echo "Cloning needed repos" #trigger build
git clone --depth=1 -b master https://github.com/MASTERGUY/proton-clang clang
git clone --depth=1 https://github.com/RooGhz720/Anykernel3 -b another AnyKernel
echo "Done"
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
export CONFIG_PATH=$PWD/arch/arm64/configs/vayu_defconfig
PATH="${PWD}/clang/bin:$PATH"
export ARCH=arm64
export KBUILD_BUILD_HOST=MyLabs
export KBUILD_BUILD_USER="Aghisna"
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot5873249679:AAFmU6zo05NZsAeDcMnubJ1PNN2yxiuBnpE/sendMessage" \
        -d chat_id="-1001692964868" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Testing build vayu kernel"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot5873249679:AAFmU6zo05NZsAeDcMnubJ1PNN2yxiuBnpE/sendDocument" \
        -F chat_id="-1001692964868" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot5873249679:AAFmU6zo05NZsAeDcMnubJ1PNN2yxiuBnpE/sendMessage" \
        -d chat_id="-1001692964868" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
 make vayu_defconfig O=out
    make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip
  cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Vayu-KSU-${TANGGAL}.zip *
    curl --upload-file ./Vayu-KSU-${TANGGAL}.zip https://transfer.sh/Vayu-KSU-${TANGGAL}.zip
    cd ..
}
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
finerr
push
