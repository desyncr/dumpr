# Initializing default values
DEF_LIST_NAME=${const.default.list.filename};
DEF_TMP_NAME=${const.default.tmp.filename};
DEF_TMP_PATH=${const.default.working.path};
TMP_LIST=$DEF_TMP_PATH$DEF_LIST_NAME-$RANDOM;

src=${const.default.list.filename};
type=${const.default.target.type};
dest=${const.default.dest.path};
conf=${const.default.conf.path};
retry=${const.default.conf.retry};
recursive=${const.default.conf.recursive};
recursion_depth=${const.default.conf.recursion_depth};
log=${const.default.log};
quiet=${const.default.quiet};
logfilename=${const.default.log.filename};
offset=0; length=0; alerts=0;
proxy_port="";
update=0;
timestamp=0;