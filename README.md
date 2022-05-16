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
- CGI 4.54 
- [ImageMagick 7.1.0-33](https://imagemagick.org/script/download.php) (With zlib, PNG, JPEG, and Perl support enabled.)

# ImageMagick Installation

ImageMagick can be difficult to install, with very few resources on the web on how to do it correctly.
The two following methods demonstrate how to do it in Debian.

## Installing with a Package Manager
```bash
sudo apt-get build-dep imagemagick
```
or

## Installing from Source

Prerequisite before compiling sources, this allows ImageMagick to detect zlib and libpng.
```bash
sudo apt install pkg-config
```
Download ImageMagicks source and use the following to compile and install it.
```bash
./configure --with-perl=yes
make
make install
```

If ImageMagick still can't see zlib, libpng, or any of the other libraries this might help.
```bash
sudo ldconfig /usr/local/lib
```

This will tell you if ImageMagick installed correctly by listing the all formats it was able to detect.
```bash
magick identify -list format 
```

# Run `chmod` to make the following file and directories writable.

```profilemanager.dat``` The database used for user profiles found in the Fanfare section.
```/``` The root directory where sessions are tracked (files ending in .sid).

```/eccoserv/avatars``` Used for avatars found in user profiles (the Fanfare section).
```/eccoserv/fanart``` Used for uploaded artwork and thumbnails.
```/eccoserv/fanfiction``` Used for uploaded text documents.
```/eccoserv/mp3``` Used for uploaded music.
```/wiki``` Where all the editable pages on the website are stored.

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


