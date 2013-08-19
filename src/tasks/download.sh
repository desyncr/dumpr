#!/bin/bash
(( ! $# )) && usage && exit

paramsParse $* && configLoad
listInitialize

##
## Main loop
##
# Displaying use settings
debug=0
(( ! $quiet )) && [[ -e BANNER ]] && cat $BANNER
[[ $type == "list" && ! -e $src ]] && echo "File list doesn't exists!: $src" && exit

# Creating an array from the source list
listParse $src

timestamp=$(stat --printf "%Y" "$src");
[[ $timestamp == 0 ]] && echo "Can't read file list!" && exit

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
            filename=$(basename "$url");
            filename=$(urldecode "$filename");

            # if there is the recursion option enabled and we're going into
            # some subfolders then we have to deal with the creation of these
            # folders locally. We don't deal with directory creation unless
            # there is the case of recursive dumping.
            if (( $recursive )); then
                relative_path=`$HELPER_PATH relative-path $base $url`;
                relative_path=$(urldecode "$relative_path");
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

        if (( $debug )); then
            sleep 1
        else
            `curl $params $proto $proxy_port  --output "$dest/$relative_path/$filename" -C - --retry $retry "$url"`;
        fi;
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
                log 'Updating list file';
                items=();
                listParse "$src";
                listItems $items;
                log '';

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
