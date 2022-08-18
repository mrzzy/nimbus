#!/bin/sh
#
# Nimbus
# Media Streaming Service
# Move Completed Script
#

set -ex -o pipefail

# Usage: move_completed.sh <DOWNLOAD> <SRCDIR> <DESTDIR>
# Move the complete download the the given path to the given destination dir.
#
# Maintains the relative path of the download with the given source dir in the
# destination dir when moving files.
#
# Arguments:
#   <DOWNLOAD>    Absolute path to the downloads to move located within <SRCDIR>.
#   <SRCDIR>      Absolute path to source directory that contains the downloaded files.
#   <DESTDIR>     Absolute path to the destination directory to move the downloaded files to.
#

# check no. of args
if [[ $# -ne 3 ]]; then
  echo "move_completed.sh: Expected 3 arguments" >&2
  exit 1
fi

# parse args: remove trailing slashes from dirs
DOWNLOAD="$1"
SRCDIR=$(printf "$2" | sed -e "s:/$::")
DESTDIR=$(printf "$3" | sed -e "s:/$::")

# perform move of downloads
DESTPATH=$(printf "$DOWNLOAD" | sed -e "s:$SRCDIR:$DESTDIR:")
DESTDIR=$(dirname "$DESTPATH")
mkdir -p "$DESTPATH"
mv -f "$DOWNLOAD" "$DESTPATH"
