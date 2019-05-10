#!/bin/bash

rm -rf repo
mkdir repo

rm -rf build
mkdir build
cd build

for i in gdal kdu expat proj sqlite ecw tiff
do
  cmake3 .. -DNAME=$i
  cpack3 -G RPM
  mv *.rpm ../repo
  rm -rf *
done

cd ../repo
createrepo .
cd ..
tar czvf repo.tgz repo
