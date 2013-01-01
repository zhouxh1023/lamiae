#!/usr/bin/env bash
# LAMIAE_DIR should refer to the directory in which sandbox is placed, the default should be good enough.
#LAMIAE_DIR=~/lamiae
#LAMIAE_DIR=/usr/local/lamiae
LAMIAE_DIR=$(dirname $(readlink -f $0))

LAMIAE_OPTIONS=""
LAMIAE_HOME="${HOME}/.lamiae"
LAMIAE_SUFFIX=".bin"
LAMIAE_EXEC=""
LAMIAE_PLATFORM=""

case $(uname -s) in
Linux)
    LAMIAE_PLATFORM="unix"
    ;;
FreeBSD)
    LAMIAE_PLATFORM="bsd"
    ;;
*)
    LAMIAE_PLATFORM="unk"
    ;;
esac


case $(uname -m) in
i386|i486|i586|i686)
  MACHINE_BIT=32
  ;;
x86_64|*)
  MACHINE_BIT=64 #assume 64bit otherwise
  ;;
esac

while [ $# -ne 0 ]
do
	case $1 in
		"-h"|"-?"|"-help"|"--help")
			echo ""
			echo "Lamiae Launching Script"
			echo "Example: ./lamiae.sh --debug -t1"
			echo ""
			echo "   Script Arguments"
			echo "  -h|-?|-help|--help	show this help message"
			echo "  --force-32		forces use of 32bit executables on architectures other than i486, i586 and i686"
			echo "  --force-64		forces use of 64bit executables on architectures other than x86_64"
			echo "			NOTE: your architecture ($(uname -m)) can be queried via \"uname -m\""
			echo "  --force-unix		forces use of Linux binaries when outside Linux"
			echo "  --force-bsd		forces use of the BSD binaries when outside BSD"
			echo "			NOTE: your platform ($(uname -s)) can be queried via \"uname -s\""
			echo ""
			echo "  --debug		starts the debug build(s) inside GDB"
			echo "			note that all arguments passed to this script will be"
			echo "			passed to lamiae when 'run' is invokved in gdb."
			echo "			it's recommended that you do this in windowed mode (-t0)"
			echo ""
			echo "   Engine Options"
			echo "  -q<string>		use <string> as the home directory (default: ${LAMIAE_HOME})"
			echo "  -k<string>		mounts <string> as a package directory"
			echo "  -t<num>		sets fullscreen to <num>"
			echo "  -d<num>		runs a dedicated server (0), or a listen server (1)"
			echo "  -w<num>		sets window width, height is set to width * 3 / 4 unless also provided"
			echo "  -h<num>		sets window height, width is set to height * 4 / 3 unless also provided"
			echo "  -z<num>		sets depth (z) buffer bits (do not touch)"
			echo "  -b<num>		sets colour bits (usually 32 bit)"
			echo "  -a<num>		sets anti aliasing to <num>"
			echo "  -v<num>		sets vsync to <num> -- -1 for auto"
			echo "  -t<num>		sets fullscreen to <num>"
			echo "  -s<num>		sets stencil buffer bits to <num> (do not touch)"
			echo "  -l<string>		loads map <string> after initialisation"
			echo "  -x<string>		executes script <string> after initialisation"
			echo ""
			echo "Script by Kevin \"Hirato Kirata\" Meyer"
			echo "(c) 2012-2013 - zlib/libpng licensed"
			echo ""

			exit 1
		;;
	esac

	tag=$(expr substr "$1" 1 2)
	argument=$(expr substr "$1" 3 1022)

	case $tag in
		"-q")
			LAMIAE_HOME="\"$argument\""
		;;
		"--")
			case $argument in
			"force-32")
				MACHINE_BIT=32
			;;
			"force-64")
				MACHINE_BIT=64
			;;
			"force-unix")
				LAMIAE_PLATFORM="unix"
			;;
			"force-bsd")
				LAMIAE_PLATFORM="bsd"
			;;
			"debug")
				LAMIAE_SUFFIX=".dbg"
				LAMIAE_EXEC="gdb --args"
			;;
			esac
		;;
		*)
			LAMIAE_OPTIONS+=" \"$tag$argument\""
		;;
	esac

	shift
done

function failed {
	echo ""
	echo "${LAMIAE_DIR}/bin_${LAMIAE_PLATFORM}/lamiae${MACHINE_BIT}${LAMIAE_SUFFIX} does not exist and the program is unable to launch as a result."
	echo "This is typically due to there not being an available build for your system."
	echo ""
	echo "If you believe this is in error, try some combination of the --force flags or if not,"
	echo "make sure that you have the sdl, sdl-image, sdl-mixer, and zlib DEVELOPMENT libraries installed."
	echo "Then execute \"make -C ${LAMIAE_DIR}/src install\" before trying this script again."
	echo ""
	exit 1
}

cd ${LAMIAE_DIR}
if [ -a bin_${LAMIAE_PLATFORM}/lamiae${MACHINE_BIT}${LAMIAE_SUFFIX} ]
then
	eval ${LAMIAE_EXEC} ./bin_${LAMIAE_PLATFORM}/lamiae${MACHINE_BIT}${LAMIAE_SUFFIX} -q${LAMIAE_HOME} ${LAMIAE_OPTIONS}
else
	failed
fi
