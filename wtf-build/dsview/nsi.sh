#!/usr/bin/bash

cd /dsview/sigrok-util/cross-compile/mingw-dsview/build_release_64/DSView
cp ~/contrib/* contrib/.

TARGET="x86_64"
echo "creating NSIS installer ..."

if [ $TARGET = "i686" ]; then
	makensis contrib/dsview_cross.nsi
else
	makensis -DPE64=1 contrib/dsview_cross.nsi
fi

echo "cross compile script done."

cd