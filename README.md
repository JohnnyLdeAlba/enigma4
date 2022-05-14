# Enigma4

A perl based wiki made in 2008 that uses the file system as database storage.

# Required Packages

Perl 5 based.

CGI
ImageMagick

# ImageMagick Installtion

sudo apt-get build-dep imagemagick

or

sudo apt install pkg-config // Required in order for ImageMagick's configure script to detect zlib and png support.
./configure --with-perl=yes
make
make install

# Setting up the config file (Optional)

```perl
abs_path('.') =~ m/(.*)\//;
$_config{ROOT_PATH} = $1;

$_config{DEVELOPER_MODE} = 1;
$_config{WEB_HOST} = "enigma4.nexusultima.com";

$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";
$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";
$_config{WIKI_PATH} =  "$_config{ROOT_PATH}/wiki";
$_config{FLOOD_INTERVAL} = 15;
$_config{DEFCON} = 2;
```

# chmod Folders.

profilemanager.dat - Profile database used for the Fanfare section.
/ - Where daily session data gets stored.
/eccoserv/avatars
/eccoserv/fanart
/eccoserv/fanfiction
/eccoserv/mp3
/wiki
