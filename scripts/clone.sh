#!/bin/bash

set -e

git clone --branch script https://github.com/IgorGepich/mediamtx.git

cd mediamtx

mv scripts ..

cd ..

rm -rf mediamtx/

git clone --branch mediamtx https://github.com/IgorGepich/mediamtx.git

cd scripts

./install_all.sh