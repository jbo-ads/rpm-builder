#!/bin/bash

rm -rf build
mkdir build
cd build

if [ $# -ne 1 ]
then
  printf "$0: Error: need exactly one component name\n" 1>&2
  exit 1
fi

name=$1

#
# Check installation
#
idir=~/install/$name
if [ ! -d $idir ]
then
  printf "$0: Error: component \"%s\" has not been found in \"%s/\"\n" \
                              $name                     $(dirname $idir) 1>&2
  exit 1
fi

#
# Update RPATH/RUNPATH in ELF files so that relative ../lib directory
# is taken into account
#
bins=$(file $(find $idir -type f) | awk -F: '/ELF 64-bit LSB exec/{print$1}')
libs=$(file $(find $idir -type f) | awk -F: '/ELF 64-bit LSB shared/{print$1}')

for i in $bins
do
  rpath=$(patchelf --print-rpath $i)
  if ! grep -q ORIGIN <<< $rpath
  then
    patchelf --set-rpath '$ORIGIN/../lib:'$rpath $i
  fi
done

for i in $libs
do
  rpath=$(patchelf --print-rpath $i)
  if ! grep -q ORIGIN <<< $rpath
  then
    patchelf --set-rpath '$ORIGIN:'$rpath $i
  fi
done

#
# Pack installation in RPM
#
cmake3 -DNAME=$name ..
cpack3

cp *.rpm ..
