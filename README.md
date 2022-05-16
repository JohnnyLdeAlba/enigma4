This README is a rough draft work in progress!

# Enigma 4 Beta

A perl based wiki made in 2008 that uses the file system as database storage.

# Features
- Anonymously create and edit pages without having to login to an account.
- Fanfare section allows anyone to create personal profiles with contact information and contributions to the website.
- An image gallery that generates thumbnails and inserts them into the users page of choice.
- Upload other contributions such as stories (in various text formats) and mp3s.

# Requirements

- Perl v5.32.1
- CGI
- ImageMagick 7.1.0-33 https://imagemagick.org/script/download.php
with PNG, JPG zlib support enabled.

# ImageMagick Installation

ImageMagick is hard to install! This might help as there aren't very good resources on the net.

sudo apt-get build-dep imagemagick

or

sudo apt install pkg-config // Required in order for ImageMagick's configure script to detect zlib and png support.
./configure --with-perl=yes
make
make install
sudo ldconfig /usr/local/lib

# Setting up the config.pm file (Optional)

```perl
abs_path('.') =~ m/(.*)\//;
$_config{ROOT_PATH} = $1;                                   # Automatically detects the absolute path of the project.

$_config{DEVELOPER_MODE} = 1;                               # Switches between localcost (127.0.0.1) to the value contained in $_config{WEB_HOST}
$_config{WEB_HOST} = "enigma4.nexusultima.com";

$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";    # Path where all the scripts are contained.
$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";   # Path where all the resources such as images and other data are contained.
$_config{WIKI_PATH} =  "$_config{ROOT_PATH}/wiki";          # Path where all the pages on the website and their histories are stored.
$_config{FLOOD_INTERVAL} = 15;                              # Flood Interval used to prevent double posting on various parts of the system (such as comments).
$_config{DEFCON} = 2;                                       # Used to lock down the system into various states. 
                                                            # Defcon 2 locks down: file uploads and profile creation
```

# chmod Folders.

```
profilemanager.dat - Profile database used for the Fanfare section.
/ - Where daily session data gets stored.
/eccoserv/avatars
/eccoserv/fanart
/eccoserv/fanfiction
/eccoserv/mp3
/wiki
```
