#!/bin/bash

rm -rf repo
mkdir repo

rm -rf build
mkdir build
cd build

for i in gdal kakadu libexpat libtiff proj sqlite3
do
  cmake3 ../$i
  cpack3
  mv *.rpm ../repo
  rm -rf *
done

cd ../repo
createrepo .
cd ..
tar czvf repo.tgz repo
