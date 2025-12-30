FROM --platform=linux/amd64 ubuntu:24.04

ENV ARCH=arm64

RUN apt update && apt upgrade -fy && \
    apt install -y \
      git openjdk-8-jdk git-core gnupg flex bison gperf build-essential zip \
      curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
      x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils \
      xsltproc unzip liblz4-tool vboot-utils u-boot-tools \
      device-tree-compiler wget zsh tmux xz-utils python3 python-is-python3 p7zip-full android-sdk-libsparse-utils \
        default-jdk libc6-dev libncurses-dev libreadline-dev libgl1 \
        make gcc g++ bc grep tofrodos python3-markdown zlib1g-dev libtinfo6 \
        repo cpio kmod openssl libelf-dev libssl-dev --fix-missing 

RUN mkdir /toolchain

RUN cd /tmp && \
	  wget --no-verbose https://github.com/ravindu644/Android-Kernel-Tutorials/releases/download/toolchain/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz 2>/dev/null >/dev/null && \
		tar xf arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz -C /toolchain && \
		mv /toolchain/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu /toolchain/gcc

RUN mkdir -p /toolchain/clang/ && \
    cd /tmp/ && \
	  wget --no-verbose https://github.com/ravindu644/Android-Kernel-Tutorials/releases/download/toolchain/clang-r383902.tar.gz 2> /dev/null >/dev/null && \
		tar xf clang-r383902.tar.gz -C /toolchain/clang/

ENV BUILD_CROSS_COMPILE="/toolchain/gcc/bin/aarch64-none-linux-gnu-"
ENV BUILD_CC="/toolchain/clang/bin/clang"

RUN cd /tmp && \
    wget https://github.com/topjohnwu/Magisk/releases/download/v30.6/Magisk-v30.6.apk  && \
		unzip Magisk-v30.6.apk && \
		chmod +x lib/x86_64/libmagiskboot.so && \
		mv lib/x86_64/libmagiskboot.so /usr/bin/magiskboot
	
RUN cd && mkdir -p .config && git clone https://github.com/olaaaf/neovim.git .config/nvim

COPY deploy.sh /usr/bin/deploy
RUN chmod +x /usr/bin/deploy
COPY gitignore /.gitignore_global

RUN git config --global core.excludesfile /.gitignore_global

RUN echo "export ARGS='-C /kernel O=/kernel/out -j$(nproc) ARCH=arm64 CROSS_COMPILE=${BUILD_CROSS_COMPILE} CC=${BUILD_CC} CLANG_TRIPLE=aarch64-none-linux-gnu- KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y'" >> /root/.bashrc

RUN echo "echo 'Put boot.bin into the output folder, run deploy to repack it with the custom kernel'" >> /root/.bashrc

RUN echo "alias vi=nvim" >> /root/.bashrc
RUN cd /tmp && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
	  rm -rf /opt/nvim-linux-x86_64 && \
		tar -C /opt -xzf nvim-linux-x86_64.tar.gz
	
RUN echo "export PATH='$PATH:/opt/nvim-linux-x86_64/bin'" >> /root/.bashrc
