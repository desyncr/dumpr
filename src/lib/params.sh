#!/bin/bash
# Parsing user params
function paramsParse() {
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
}
