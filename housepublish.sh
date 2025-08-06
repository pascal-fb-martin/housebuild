#!/bin/bash
#
# Copyright 2025, Pascal Martin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA  02110-1301, USA.
#
# HousePublish: install all listed debian package to the local repository.
#


. /etc/os-release
release=$VERSION_CODENAME
version=`cat /etc/debian_version`
suite=stable
arch=`dpkg --print-architecture`

packages=

for a in $* ; do
   case $a in
     --arch=*)
         array=(${a//=/ })
         arch=${array[1]}
         ;;
     --release=*)
         array=(${a//=/ })
         release=${array[1]}
         ;;
     --suite=*)
         array=(${a//=/ })
         suite=${array[1]}
         ;;
     *)
         packages="$packages $a"
         ;;
   esac
done

root=/usr/local/share/house/public/debian
base=$root/dists/$release
index="$base/main/binary-$arch"

install -m 0755 -d $root/pool
for p in $packages ; do
   install -m 0644 $p $root/pool
done

echo "== Building package index $index/Packages.gz"
install -m 0755 -d $index
(cd $root ; dpkg-scanpackages --arch $arch pool/ | gzip -9 > $index/Packages.gz)

echo "== Building release file $base/Release"
compute_hashes() {
  command=$2
  echo "${1}:"
  for f in $(find -type f) ; do
    f=$(echo $f | cut -c3-)
    if [ "$f" = "Release" ] ; then continue ; fi
    echo " $(${command} ${f} | cut -d" " -f1) $(wc -c $f)"
  done
}

cd $base
rm -f Release
echo "Origin: House" >> Release
echo "Label: House" >> Release
echo "Suite: $suite" >> Release
echo "Version: $version" >> Release
echo "Codename: $release" >> Release
echo "Date: $(date -Ru)" >> Release
echo "Architectures: all $arch" >> Release
echo "Components: main" >> Release
echo "Description: The House software suite repository" >> Release

compute_hashes "MD5Sum" "md5sum" >> Release
compute_hashes "SHA1" "sha1sum" >> Release
compute_hashes "SHA256" "sha256sum" >> Release

