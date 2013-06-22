#!/bin/bash

# Parse a raw list of items into an array
function listParse {
    i=0;
    for item in `cat $1`; do
        items[i]=$item;
        let i++;
    done;
}

# Creates a download list from a remote directory listing.
function listLoad {
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

function listInitialize() {
    # Remote lists and files are 'transformed' into local lists.
    case    "$type" in
        remote | create-list)
            log "Retrieving remote list...";

            :>$TMP_LIST; # cleaning out download list
            listLoad "$src/" "$TMP_LIST";
            case    !? in
                0)
                    log "Remote list retrieved successfully.";
                ;;
                1)
                    log "Error retrieving remote list. Aborting." $alerts;
                    exit 1;
                ;;
            esac;

            src=$TMP_LIST;
            checklist $src;
            if (( $? )); then # $? != 0
                log "Error retrieving download list. Aborting." $alerts;
                exit 1;
            fi;

            if [[ $type == "create-list" ]]; then
                log "List successfully created.";
                cat $src;
                exit 0;
            fi;
        ;;
        list)
            checklist $src;
            case    $? in
                1)
                    log "No list found on '$src'. Aborting." $alerts;
                    exit 1;
                ;;
                2)
                    log "Empty download list '$src'. Aborting." $alerts;
                    exit 2;
                ;;
                0)
                    log "List file '$src' loaded.";
                ;;
            esac;
        ;;
        file)
            echo $src > $TMP_LIST;
            src=$TMP_LIST;
        ;;
    esac;
}
