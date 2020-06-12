#!/bin/bash

echo "Download Boost ver. 1.68.0 from https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz"
echo -n "Proceed? [Any keys to continue, otherwise CTRL+C to exit] "
read dummy

rm -rf boost boost_1_68_0 boost_1_68_0.tar.gz

wget https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz && \
    tar xvfz boost_1_68_0.tar.gz && \
    cd boost_1_68_0 && \
    ./bootstrap.sh --prefix=$PWD/../boost && \
    ./b2 install --prefix=$PWD/../boost -q && \
    echo -e "\nINFO: Boost ver. 1.68.0 downloaded, check SHA256 hash at https://www.boost.org/users/history/version_1_68_0.html"
