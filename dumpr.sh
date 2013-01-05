#!/bin/bash
# Download manager/queue downloader.
# 
#   ./dumpr.sh --url|--file|--list url|list [--dest][--config][--create-list][--retry][--hash][--on-complete]
# 
# Example:
#   ./dumper.sh --list=list.txt --dest=~/downloads/dest
# 
#   Will open `list.txt` on current directory to read its contents.
#   From `list.txt` the script will take the items to download.
# 
#   `~/downloads/dest` is the destination directory for the downloaded files.
# 
#   --list-only: Only download the directory listing (--url) and create a download list.
#   --config: Point to the configuration file.
#   --alerts: Display alets on download complete.
#   --quiet: Don't show any message.
#   --param: Params to pass to Curl.
#   --retry: Retry attempts.
#   --hash: If make an md5 hash of the downloaded items.
#   --on-complete: Executes a program or script, or commands, on download completion.
# 
# More examples:
#   asphyxia@dev$ dumpr.sh --url=http://localhost/music/ --dest=~/downloads/music/
# 
#   Version: ${version.number}
#   Build time: @BUILDTIMESTAMP@
{?lib/header.sh?}
{?lib/functions.sh?}
##
## Main program
##
# Parsing user params
if (( ! $# )); then usage; exit 1; fi;
while [[ $1 ]]; do
    case    $1 in
        -l=* | --list=*)    # Will take the list of files to download from a local file.
            src=${1##*=};
            type="list";
        ;;
        -u=* | --url=*)     # Will retrieve the list from a remote directory listing.
            src=${1##*=};
            src=${src%%\/}; # stripping training slash.
            base=$src;
            type="remote";
        ;;
        -f=* | --file=*)    # Will download a single file.
            recursive=0;
            src=${1##*=};
            type="file";
        ;;
        -o=* | --offset=*)  # offset in the format: from,len
            offsets=${1##*=};
            offset=${offsets%%,*};
            length=${offsets##*,};
            (( !$offset )) && offset=0;
            (( !$length )) && length=0;
        ;;
        --alerts)           # Use alerts for finished, failed etc, downloads.
            alerts=1;
        ;;
        -lo | --list-only)
            type="create-list";
        ;;
        -r=* | --recursive=* )
            recursive=${1##*=};#true or false
        ;;
        -b=* | --base=*)    # Base url when using recursive listing.
            base=${1##*=};
            base=${base%%\/}
        ;;
        -d=* | --dest=*)    # By default it uses the current directory.
            dest=${1##*=};
            dest=${dest%%\/}
        ;;
        -c=* | --config=* | --conf=*)  # Will read proxy configuration from a file.
            conf=${1##*=};
        ;;
        -r=* | --retry=*)   # Retry count. Default 10.
            retry=${1##*=};
        ;;
        --params=*)         # Custom params passed to curl.
            params=${1##*=};
        ;;
        --quiet)            # No banner
            quiet=1;
            verbosity=0;
        ;;
        --log)              # Log debug strings to file
            log=1;
        ;;
        -md5 | --hash)      # Perform an Md5 hash over the downloaded files.
            hash=1;
        ;;
        -x=* | --on-complete=*) # Launch a determined script or binary on download completion.
            launch=${1##*=};
        ;;
        --update)  # Update list items as the file list is changed
            update=1;
        ;;
        -h | --help)        # Display help information.
            usage;
            exit 0;
        ;;
        -v | --version)     # Display version information.
            $ already displayed into the banner
            exit 0;
        ;;
    esac;
    shift;
done;


# Support params and default values (omited params) using config file.
if [[ -e $conf ]]; then
    loadconf $conf;
    case    $? in
        1)
            log "Error loading configuration. Bad configuration file." $alerts;
            exit 1;
        ;;
        *)
            log "Configuration file '$conf' loaded.";
        ;;
    esac;
else
    log "Warning: No proxy configuration loaded." $alerts;
fi;

# Remote lists and files are 'transformed' into local lists.
case    "$type" in
    remote | create-list)
        log "Retrieving remote list...";

        :>$TMP_LIST; # cleaning out download list
        retrivelist "$src/" "$TMP_LIST";
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
timestamp=$(stat --printf "%Y" "$src");

##
## Main loop
##
# Displaying use settings
(( ! $quiet )) && cat ${directories.configuration}${const.default.banner.filename};

# Creating an array from the source list
parselist $src

success=0; failed=0; total=0; $downloaded_items;
total=${#items[@]};
(( !$length )) && length=$total;

(( !$quiet )) && showsettings;

while (( 1 )); do
    url=${items[$offset]};
    for try in `seq 1 $retry`; do
        log "Downloading $url ($try)";

        if (( $try == 1 )); then
            # Decoding the file name and adding it to the list of items to hash at the end of the script.
            filename=`${const.default.helper.path} filename $url`;
            filename=`${const.default.helper.path} decode $filename`;

            # if there is the recursion option enabled and we're going into
            # some subfolders then we have to deal with the creation of these
            # folders locally. We don't deal with directory creation unless
            # there is the case of recursive dumping.
            if (( $recursive )); then
                relative_path=`${const.default.helper.path} relative-path $base $url`;
                relative_path=`${const.default.helper.path} decode "$relative_path"`;
                if [[ ! -e "$dest/$relative_path" ]]; then
                    log "Creating directory: '$dest/$relative_path'...";
                    mkdir -p "$dest/$relative_path";
                fi;
            fi;

            # Intentionally here. The item here actually wasn't downloaded. It's about
            # to be download, and can fail its download. The point is that
            # if it fails, the md5sum will fail also to hash it (because it doesn't
            # exists locally) so it's easier to notice which items failed to download.
            # For the actual completed downloads use the "success" file.
            downloaded_items="$downloaded_items '$dest/$relative_path/$filename'";
        fi;

        `curl $params $proto $proxy_port  --output "$dest/$relative_path/$filename" -C - --retry $retry "$url"`;
        if (( ! $? )); then
            break;
        fi;
    done;

    # We reached the retry count. Could not download the file.
    if (( $try == $retry )); then
        echo $url >> "$dest/failed";
        log "Download failed: $url" $alerts;
        let failed++;
    else
        echo "$dest/$filename">>"$dest/success";
        log "Download complete: $url" $alerts;
        let success++;
    fi;
    log "$success successful downloads. $failed failed. $success/$total items downloaded.";
    (( ! $quiet )) && echo;

    # Launch a given binary of script (or a line of commands)
    if [[ $launch ]]; then
        field=1;
        # scripts, binary programs or single commands *must* be ended with a ';'. Otherwise
        # they will be ignored.
        while [[ "`echo $launch | cut -s -d";" -f$field`" != "" ]]; do
            command=`echo $launch | cut -s -d";" -f$field`;
            eval $command;
            let field++;
        done;
    fi;
    # Check if we have to update the list as it changes
    if [[ $update ]]; then
        if [[ $type == 'list' ]]; then
            tsupdate=$(stat --printf '%Y' $src);
            if [[ $timestamp != $tsupdate ]]; then
                echo 'Updating list file';
                items=();
                parselist "$src";
                listitems $items;
                echo "";

                total=${#items[@]};
                length=$total;

                timestamp=$tsupdate;
            fi;
        fi;
    fi;

    let offset++;
    if (( $offset >= $total )); then
        break;
    fi;
done;

if (( $hash )); then
    log "MD5 of downloads:";
    log `md5sum $downloaded_items | tee -a "$dest/md5s"`;
fi;

[[ -e $TMP_LIST ]] && rm $TMP_LIST;
log "Script finished. `date`" $alerts;
exit $failed;
