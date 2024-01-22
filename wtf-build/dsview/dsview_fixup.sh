#!/usr/bin/bash

# these need to be done by dsview-cross-mingw after clone and before make
cp ~/CMakeLists.txt .
# still need?  <5.11 qt
sed -ri 's/horizontalAdvance/width/' DSView/pv/dialogs/deviceoptions.cpp
sed -ri 's/horizontalAdvance/width/' DSView/pv/dock/measuredock.cpp

cp -r ~/contrib .
