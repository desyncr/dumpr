function usage() {
  cat <<EOF
                         8888888b.                                          
                         888  "Y88b                                         
                         888    888                                         
                         888    888 888  888 88888b.d88b.  88888b.  888d888 
                         888    888 888  888 888 "888 "88b 888 "88b 888P"   
                         888    888 888  888 888  888  888 888  888 888     
                         888  .d88P Y88b 888 888  888  888 888 d88P 888     
                         8888888P"   "Y88888 888  888  888 88888P"  888     
                                                           888              
                         Download manager/queue downloader 888              
                                                           888              
EOF
echo 

cat <<EOF
   ./dumpr.sh --url|--file|--list url|list [--dest][--config][--create-list][--retry][--hash][--on-complete]
EOF
echo 

cat <<EOF
 Example:
   ./dumper.sh --list=list.txt --dest=~/downloads/dest
EOF
echo 

cat <<EOF
   Will open 'list.txt' on current directory to read its contents.
   From 'list.txt' the script will take the items to download.
EOF
echo 

cat <<EOF
   '~/downloads/dest' is the destination directory for the downloaded files.
EOF
echo 

cat <<EOF
   --list-only: Only download the directory listing (--url) and create a download list.
   --config: Point to the configuration file.
   --alerts: Display alets on download complete.
   --quiet: Don't show any message.
   --param: Params to pass to Curl.
   --retry: Retry attempts.
   --hash: If make an md5 hash of the downloaded items.
   --on-complete: Executes a program or script, or commands, on download completion.
   --update: Update download list as it changes on disk (--list).
   --log: Enables logging to file.
EOF
echo 

cat <<EOF
 More examples:
   asphyxia@dev$ dumpr.sh --url=http://localhost/music/ --dest=~/downloads/music/
EOF
echo 

cat <<EOF
   Build time: $BUILD_TIME
   Version: $VERSION_NUMBER
EOF
echo 
}
