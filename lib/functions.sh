##
## Helper functions
##

# Logging info to strout and/or file
function log
{
    (( ! $quiet )) && echo $1;
    (( $2 )) && `kdialog --title ${const.default.alert.title} --passivepopup "$1"`;
    (( $log )) && echo "[`date`] [ $logfilename ] $1" >> $logfilename;
}

# Displaying help information out of the script itself (talking about self-documenting)
function usage
{
    # Reads the first 22 lines from the script itself; removes the "#" of comments;
    # and ignores the first line (with 'more +2') which is "#!/bin/bash"
    head -n 22 $0 | cut -d"#" -f2 -s | more +2
}

# Checking the existence of the list file and if it's empty.
function checklist
{
    if [[ -e $1 ]]; then
        if [ "`wc -l $1 | cut -d' ' -f1`" == "0" ]; then
            return 2;
        fi;
    else
        return 1;
    fi;
}

# Read configuration file and set up proxy settings.
function loadconf
{
    for line in `cat $1`; do
        key=${line%%=*};
        value=${line##*=};

        case    $key in
            proxy)
                proxy=$value;
            ;;
            port)
                port=$value;
            ;;
            proto)
                proto=$value;
            ;;
        esac;
    done;

    [[ ! $proxy || ! $port || ! $proto ]] &&  ( return 1 );
    proxy_port="$proxy:$port";
}

# Initialize main loop variables
function initialize
{
    items=$1;
    total=${#items[@]};
    (( !$length )) && length=$total;
}

# List current items
function listitems
{
    i=0;
    items=$1;
    for item in ${items[@]}; do
        log "[$i] $item";
        let i++;
    done;
}

# Shows current settings.
function showsettings
{
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
    listitems $items;

cat <<-EOF

    Total $total item(s) queued for download.
    Download started: `date`;

EOF
}

# Parse a raw list of items into an array
function parselist
{
    i=0;
    for item in `cat $1`; do
        items[i]=$item;
        let i++;
    done;
}

# Creates a download list from a remote directory listing.
function retrivelist
{
    `curl $params $proto $proxy_port  -s --output "$DEF_TMP_NAME" --retry $retry $1`; # it's a directory so it needs a trailing slash or you will get 301
    if (( ! $? )); then # $? == 0
        list=`"${const.default.helper.path}" list "$DEF_TMP_NAME"`;

        for url in $list; do
            # supposely it has a trailing slash for directories
            if [[ $url =~ (.*\/)$ ]]; then # a directory: .*/
                case $url in
                    "../" | "./" | "/") # meta directories

                    ;;
                    *)
                        (( $recursive )) && ( retrivelist $1$url $2);
                    ;;
                esac;
            else
                # $1 has to have a trailing slash
                echo "$1$url" >> $2;  # This is weak as some listing may display full paths.
            fi;
        done;

        return 0;
    else
        [[ -e "$DEF_TMP_NAME" ]] && ( rm "$DEF_TMP_NAME" );
        return 1;
    fi;
}