#!/bin/bash

# Read configuration file and set up proxy settings.
function configParse() {
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

# Support params and default values (omited params) using config file.
function configLoad() {
	if [[ -e $conf ]]; then
	    configParse $conf;
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
}
