#!/bin/bash

#
#  Build script for time2backup debian package
#
#  Website: https://time2backup.org
#  MIT License
#  Copyright (c) 2017-2018 Jean Prunneaux
#


# get current_directory
current_directory=$(dirname "$0")

# test if time2backup is there
if ! [ -d "$current_directory/time2backup" ] ; then
	echo "ERROR: you must put time2backup sources in the time2backup directory!"
	exit 1
fi


###############
#  FUNCTIONS  #
###############

# Print usage
print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "   -v, --version VERSION  Specify a version"
	echo "   -h, --help             Print this help"
}


##################
#  MAIN PROGRAM  #
##################

# get options
while [ $# -gt 0 ] ; do
	case $1 in
		-v|--version)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			version=$2
			;;
		*)
			break
			;;
	esac
	shift
done

# prompt to choose version
if [ -z "$version" ] ; then
	version=$(grep "^version=" "$current_directory/time2backup/time2backup.sh" | head -1 | cut -d= -f2)

	echo -n "Choose version: [$version] "
	read version_user
	if [ -n "$version_user" ] ; then
		version=$version_user
	fi

	echo
fi

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

echo "Clean files..."
sudo rm -rf package

echo
echo "Package is ready!"
