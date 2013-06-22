# Initializing default values
DEF_LIST_NAME=download.lst
DEF_TMP_PATH=/tmp/
DEF_TMP_NAME=.dumpr-$RANDOM
TMP_LIST=$DEF_TMP_PATH$DEF_LIST_NAME-$RANDOM
HELPER_PATH=~/.dumpr/share/helpers.pl
BANNER=~/.dumpr/share/banner.sh
BUILD_TIME="vie jun 21 22:17:23 ART 2013"
VERSION_NUMBER=0.129.0

src=download.lst
type=list
dest=$PWD

conf=~/.dumpr/share/conf-default
retry=10
recursive=1
recursion_depth=2

log=0
quiet=0
logfilename=log

offset=0
length=0
alerts=0
proxy_port=""
update=0
timestamp=0
