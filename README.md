## Shell Downloader
---

Dumpr is a small tool that wraps around curl to queue and download files. Handles partial and failed downloads, and re-starts the downloads automatically.

## Install
* ``curl -sSL https://raw.github.com/asphxia/dumpr/master/share/install.sh | sudo sh``
* Done

## Usage

  ``dumpr.sh --url|--file|--list url|list [--dest][--config][--create-list][--retry][--hash][--on-complete]``

### Arguments

  ``--list-only`` Only download the directory listing (``--url``) and create a download list.
  
  ``--config`` Point to the configuration file.
  
  ``--alerts`` Display alets on download complete.
  
  ``--quiet`` Don't show any message.
  
  ``--param`` Params to pass to Curl.
  
  ``--retry`` Retry attempts.
  
  ``--hash`` Make an MD5 hash of the downloaded items.
  
  ``--on-complete`` Executes a program or script, or commands, on download completion.
  

## Example ##
  ``dumper.sh --list=list.txt --dest=~/downloads/dest``

  Will open `list.txt` on current directory to read its contents.
  From `list.txt` the script will take the items to download.

  `~/downloads/dest` is the destination directory for the downloaded files.

### More examples ###
  ``dumpr.sh --url=http://localhost/music/ --dest=~/downloads/music/``


## Contact and Feedback

If you'd like to contribute to the project or file a bug or feature request, please visit [the project page][1].

## License

The project is licensed under the [GNU GPL v3][2] ([tldr][3]) license. Which means you're allowed to copy, edit, change, hack, use all or any part of this project *as long* as all of the changes and contributions remains under the same terms and conditions.

  [1]: https://github.com/asphxia/dumpr/
  [2]: http://www.gnu.org/licenses/gpl.html
  [3]: http://www.tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)
  
