#!/bin/bash

set -o nounset
set -o pipefail

DIR=$(dirname "$(readlink -f "$0")")
NAME=$(basename "$(readlink -f "$0")") 

BASE_DIR=~/.wine-appimage-staging/drive_c
DIR1="$BASE_DIR/Program Files (x86)"
DIR2="$BASE_DIR/Program Files"
WINE_BIN="/usr/local/bin/wine-staging.AppImage"

function run_wxwork() {
    local name="WXWork"
    if [ -d "$DIR1/$name" ]; then
        WXDIR="$DIR1/$name"
        EXE_PATH="$DIR1/$name/WXWork.exe"
    elif [ -d "$DIR2/$name/" ]; then
        WXDIR="$DIR2/$name"
        EXE_PATH="$DIR2/$name/WXWork.exe"
    else
        echo "WXWork.exe not found in $DIR1 or $DIR2"
        return 1
    fi
    # Delete WXWorkWeb.exe WeMail.exe
    cd "$WXDIR" && find . -type f -name "WXWorkWeb.exe" -exec mv {} {}.bk \;
    cd "$WXDIR" && find . -type f -name "WeMail.exe" -exec mv {} {}.bk \;
    "$WINE_BIN" "$EXE_PATH"
}

function usage()
{
  echo -e "
$DIR/$NAME usage:
\t -h: print help
\t -a: run app by app_name, e.g. -a wxwork
  "
  exit 0
}

function main()
{
  while getopts ":a:h" Opt; do
      case $Opt in
      a ) 
          case "${OPTARG}" in
              wxwork) run_wxwork ;;
              *) echo "Unknown app: ${OPTARG}" ; usage ;;
          esac
          ;;
      h ) usage ;;
      * ) usage ;;
      esac
  done
}

main "$@"