#!/bin/sh

## DABM 20190708
## change to root
cd /
## clone the repo
git clone https://github.com/civetweb/civetweb
## cd to repo top level and store revision
cd civetweb/
export REV=`git rev-parse --short=6 HEAD`
## create a build ir out of source for cmake and cd into ti
mkdir build-dir
cd build-dir/
## minimal configuration
cmake -DCMAKE_INSTALL_PREFIX=/opt/civetweb ..
## build
make
## test and store test results
make test | tee -a /export/tests_results_${REV}.txt
## install anyway no matter test results
make install
## got to install dir and create a deb package
cd /opt
mkdir civetweb_package_${REV}
cd civetweb_package_${REV} 
mkdir -p opt/civetweb
mkdir DEBIAN
cp -adpR /opt/civetweb/* opt/civetweb
mv /opt/control DEBIAN
## sed the revision into index.html
cp /opt/index.html .
sed -i  "s/gitrev/$REV/g" index.html
mv index.html opt/civetweb/bin
cd /opt
dpkg-deb --build civetweb_package_${REV}
## move the deb package to folder mounted in host
mv /opt/civetweb_package_${REV}.deb /export
echo $REV > /export/revision.txt

