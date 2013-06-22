Download manager/queue downloader.
==================================
## Install ##
* ``curl -sSL https://raw.github.com/asphxia/dumpr/master/share/install.sh | sh``
* Done

## Usage ##

  ``./dumpr.sh --url|--file|--list url|list [--dest][--config][--create-list][--retry][--hash][--on-complete]``

### Arguments ###

  --list-only: Only download the directory listing (--url) and create a download list.
  
  --config: Point to the configuration file.
  
  --alerts: Display alets on download complete.
  
  --quiet: Don't show any message.
  
  --param: Params to pass to Curl.
  
  --retry: Retry attempts.
  
  --hash: If make an md5 hash of the downloaded items.
  
  --on-complete: Executes a program or script, or commands, on download completion.
  

## Example ##
  ``./dumper.sh --list=list.txt --dest=~/downloads/dest``

  Will open `list.txt` on current directory to read its contents.
  From `list.txt` the script will take the items to download.

  `~/downloads/dest` is the destination directory for the downloaded files.

### More examples ###
  ``asphyxia@dev$ dumpr.sh --url=http://localhost/music/ --dest=~/downloads/music/``

