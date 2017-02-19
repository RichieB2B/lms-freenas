#!/bin/sh

# Use pkg in unattended mode
export ASSUME_ALWAYS_YES=YES

URL=$(curl -s 'http://www.mysqueezebox.com/update/?version=7.9.0&revision=1&geturl=1&os=readynas' | sed -e 's/-sparc-readynas.bin$/-FreeBSD.tgz/')
TGZ=$(basename $URL)
DIR=$(basename $TGZ .tgz)

# Install needed packages
pkg update
pkg upgrade
pkg install bash
pkg install gmake
pkg install rsync
pkg install nasm
pkg install wget
pkg install libgd
pkg install gcc

# Download LMS nightly build
mkdir /tmp/LMS
cd /tmp/LMS
wget $URL

if [ ! -f $TGZ ]; then
  echo 'Downloading $URL failed!'
  exit 1
fi

tar xf $TGZ

if [ ! -d $DIR ]; then
  echo 'Downloaded $TGZ did not contain $DIR directory!'
  exit 1
fi

# Everything is looking good to go

git clone https://github.com/Logitech/slimserver-vendor -b public/7.9
ln -s -f /usr/local/bin/perl5.24.1 /usr/bin/perl
ln -s -f /usr/local/bin/perl5.24.1 /usr/bin/perl5
cd /tmp/LMS/slimserver-vendor/CPAN
./buildme.sh | tee /tmp/LMS/buildme.sh.log
cd /tmp/LMS/$DIR/CPAN/arch/5.24
cp -Rp /tmp/LMS/slimserver-vendor/CPAN/build/arch/5.24/amd64-freebsd-thread-multi .
cd ..
rm -rf 5.8
rm -rf 5.10
rm -rf 5.12
rm -rf 5.14
rm -rf 5.16
rm -rf 5.18
rm -rf 5.20
rm -rf 5.22
cd /tmp/LMS
tar cf $DIR $DIR.tar

echo 'Building complete! The result is in $DIR.tar'
