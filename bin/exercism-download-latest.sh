#!/usr/bin/bash

# Download the release page from github/exercism/cli and search through the
# list of releases
#
# To get the list of releases we parse for the following spans:
# <span class="ml-1 wb-break-all">
# and return the next line of the html page; that will contain the version
#
# Then we grep each line for a version pattern, for example:
# v[xx].[xx].[xx]-alpha
#
# TODO: revise this procedure later in case something changes (release page, span class, etc)
vers=$(wget -q https://github.com/exercism/cli/releases -O - | sed -n '/<span class="ml-1 wb-break-all">/{n;p}' | grep -oe "[0-9]\+\.[0-9]\+\.[0-9]\+[a-z0-9\.-]*")

if [ -z "${vers}" ]; then
	echo "Unable to retrieve list of latest releases"
fi

# Turn the $vers result of the grep into an array
# Then get the latest version
vers=( $(echo "${vers}") )
latest_release=${vers[0]}
tar_file="exercism-${latest_release}-linux-x86_64.tar.gz"

echo "Downloading latest release: ${latest_release}"

# Download the latest release tarball for linux
# Place everything into a __tmp directory
mkdir __tmp
cd __tmp

wget "https://github.com/exercism/cli/releases/download/v${latest_release}/${tar_file}"
tar -xvf ${tar_file}
cp ./exercism ~/.bin

mkdir -p ~/.config/exercism
mv shell/exercism_completion.bash ~/.config/exercism/exercism_completion.bash

cd ..
rm -Rf __tmp
