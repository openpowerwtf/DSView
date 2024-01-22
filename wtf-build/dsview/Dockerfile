# set up environment for sigrok/dsview linux/win builds

FROM ubuntu:jammy as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y sudo apt-utils

RUN apt-get install -y \
        automake autoconf autoconf-archive build-essential git-core cmake \
        wget autopoint bison flex gperf libtool-bin p7zip-full lzip swig default-jdk ruby intltool \
        gcc g++ libtool pkg-config libglib2.0-dev libglibmm-2.4-dev libzip-dev \
        libusb-1.0-0-dev libftdi1-dev libieee1284-3-dev libvisa-dev nettle-dev libavahi-client-dev \
        libhidapi-dev check doxygen python3-numpy python3-dev python3-mako python-gi-dev python3-setuptools-git python-is-python3 \
        qtcreator qtbase5-dev qt5-qmake qttools5-dev libqt5svg5-dev libboost-all-dev \
        sdcc libssl-dev nsis libfftw3-dev libudev-dev nano

WORKDIR /dsview
WORKDIR /root

# pulseview, dsview linux
COPY ./build_libsigrokdecode.sh /root
COPY ./build_libsigrok.sh /root
COPY ./build_pulseview.sh /root
COPY ./build_dsview.sh /root

# mxe for crosscompile
COPY ./build_mxe.sh /root

# pulseview crosscompile
COPY ./build_pulseview_win64.sh /root

# dsview crosscompile
COPY ./sigrok_util_dsview /root
COPY ./build_dsview_win64.sh /root
COPY ./dsview_fixup.sh /root
COPY ./CMakeLists.txt /root
COPY ./contrib /root/contrib

# extra
COPY ./nsi.sh /root
COPY ./export.sh /root

RUN echo "PS1='\[\033[01;32m\]\u@dsview\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ '" >> /root/.bashrc && \
    echo 'export PATH="$PATH:/dsview/mxe/usr/bin"' >> /root/.bashrc && \
    echo 'cd' >> /root/.bashrc
