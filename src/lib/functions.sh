##
## Helper functions
##

# Logging info to strout and/or file
function log {
    (( ! $quiet )) && echo $1;
    (( $2 )) && `kdialog --title ${const.default.alert.title} --passivepopup "$1"`;
    (( $log )) && echo "[`date`] [ $logfilename ] $1" >> $logfilename;
}

# Displaying help information out of the script itself (talking about self-documenting)
function usage {
    cat $USAGE_FILE
}

# Initialize main loop variables
function initialize {
    items=$1;
    total=${#items[@]};
    (( !$length )) && length=$total;
}

# Shows current settings.
function showsettings {
    if [[ ! $proxy_port ]]; then
        proxy_setting="(No proxy)";
    else
        proxy_setting=$proxy_port;
    fi;

    if (( $log )); then
        logginfile=$logfilename;
    else
        logginfile="(No loggin)";
    fi;

    if [[ $params ]]; then
        curlparams=$params;
    else
        curlparams="(No user params)";
    fi;

    if [[ -e $conf ]]; then
        configuration=$conf;
    else
        configuration="(No configuration)";
    fi;

    cat <<-EOF;
    Settings:
        Task list           : $src
        Type                : $type
        Destination         : $dest
        Configuration       : $configuration
        Proxy               : $proxy_setting
        Retries             : $retry
        Recursion           : $recursive
        Recursion depth     : $recursion_depth
        Curl params         : $curlparams
        Loggin file         : $logginfile
        Task list item(s)   : $total

    Download list:
EOF
    listItems $items;

cat <<-EOF

    Total $total item(s) queued for download.
    Download started: `date`;

EOF
}
