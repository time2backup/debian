#!/bin/bash

#
#  Build script for time2backup debian package
#
#  Website: https://time2backup.github.io
#  MIT License
#  Copyright (c) 2017 Jean Prunneaux
#


# get current_directory
current_directory=$(dirname "$0")

# test if time2backup is there
if ! [ -d "$current_directory/time2backup" ] ; then
	echo "ERROR: you must put time2backup sources in the time2backup directory!"
	exit 1
fi

# get time2backup version
version=$(grep "^version=" "$current_directory/time2backup/time2backup.sh" | head -1 | cut -d= -f2)
if [ -z "$version" ] ; then
	echo "ERROR: Cannot get time2backup version!"
	exit 1
fi

echo -n "Build debian package for time2backup v$version? (y/N) "
read confirm
if [ "$confirm" != "y" ] ; then
	exit
fi

echo

# create build environment
mkdir -p "$current_directory/build"
if [ $? != 0 ] ; then
	echo "ERROR while creating build directory. Please verify your access rights."
	exit 3
fi

package="$current_directory/build/package"
install_path="$package/usr/src"

# clean and copy package files
echo "Clean and copy package..."
rm -rf "$package" && cp -rp "$current_directory/package" "$current_directory/build/"
if [ $? != 0 ] ; then
	echo "ERROR while copying package files. Please verify your access rights."
	exit 3
fi

echo "Set version number..."
sed -i "s/^Version: .*/Version: $version/" "$package/DEBIAN/control"
if [ $? != 0 ] ; then
	echo "ERROR while setting the package version number."
	exit 4
fi

echo "Copy time2backup sources..."

mkdir -p "$install_path" && cp -rp "$current_directory/time2backup" "$install_path"
if [ $? != 0 ] ; then
	echo "ERROR while copying sources files. Please verify your access rights."
	exit 5
fi

install_path+="/time2backup"

echo "Clean unnecessary files..."

files=(.git .gitignore .gitmodules config/.gitignore)
for f in ${files[@]} ; do
	rm -rf "$install_path"/$f
	if [ $? != 0 ] ; then
		echo "... Failed!"
		exit 5
	fi
done

echo "Set permissions..."

chmod -R 755 "$install_path" && \
chmod 644 "$install_path"/*.md "$install_path"/config/* "$install_path"/docs/* "$install_path"/inc/* "$install_path"/libbash/*.md "$install_path"/resources/* && \
sudo chown -R root:root "$install_path"
if [ $? != 0 ] ; then
	echo "... Failed!"
	exit 6
fi

# go into the build directory
cd "$current_directory/build"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to go into the build directory!"
	exit 7
fi

# set archive name
archive="time2backup-$version.deb"

echo "Generating deb package..."

dpkg-deb --build package $archive
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 8
fi

# create archive directory
mkdir -p "$version"
if [ $? != 0 ] ; then
	echo "ERROR: Cannot create archive directory!"
	exit 9
fi

# move archive above
mv "$archive" "$version"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to move the archive!"
	exit 9
fi

# going up
cd "$version"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to go into the archive directory!"
	exit 7
fi

echo "Generating checksum..."
sha256sum $archive > sha256sum.txt
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 10
fi

echo "Clean files..."
sudo rm -rf ../package

echo
echo "Package is ready!"
