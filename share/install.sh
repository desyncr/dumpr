#!/bin/sh
echo "\033[0;34mInstalling Dumpr to /usr/local/bin\033[0m"
git clone https://github.com/asphxia/dumpr.git ~/.dumpr/

echo "\033[0;34mInstalling locally /usr/local/bin/dumpr\033[0m"
ln -s ~/.dumpr/target/Dumpr-0.129.0-SNAPSHOT.sh /usr/local/bin/dumpr

echo
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
echo "\033[0;34m            Done. Now you're using Dumpr v0.129.0\033[0m"
