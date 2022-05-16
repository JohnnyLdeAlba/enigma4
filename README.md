# Enigma 4

A perl based wiki made in 2008 that uses the file system as database storage.

<img style="height: 400px;" src="https://raw.githubusercontent.com/JohnnyLdeAlba/enigma4/master/profile-sample.png" /> <img style="height: 400px;" src="https://raw.githubusercontent.com/JohnnyLdeAlba/enigma4/master/edit-sample.png" />

# Features
- Anonymously create and edit pages without having to login to an account.
- Edit history allows users to see what changes were made to a page.
- Fanfare section allows anyone to create personal profiles with contact information and contributions to the website.
- An image gallery that generates thumbnails and inserts them into the users page of choice.
- Upload other contributions such as stories (in various text formats) and mp3s.
- Supports custom themes that allow users to change how the website looks.
- Pages can support optional comment sections.

# [Example](https://enigma4.nexusultima.com)

This is the hosted version of this repo with profile creation and media uploading disabled.

# Requirements

- Perl v5.32.1
- CGI 4.54 
- [ImageMagick 7.1.0-33](https://imagemagick.org/script/download.php) (With zlib, PNG, JPEG, and Perl support enabled.)

# ImageMagick Installation

ImageMagick can be difficult to install, with very few resources on the web on how to do it correctly.
The two following methods demonstrate how to do it in Debian.

### Installing with a Package Manager
```bash
sudo apt-get build-dep imagemagick
```
or

### Installing from Source

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

This will tell you if ImageMagick installed correctly by listing all formats it was able to detect.
```bash
magick identify -list format 
```

# Make the Following File and Directories Writable

- ```profilemanager.dat``` The database used for user profiles found in the Fanfare section.

- ```/``` The root directory where sessions are tracked (files ending in .sid).
- ```/eccoserv/avatars``` Used for avatars found in user profiles (the Fanfare section).
- ```/eccoserv/fanart``` Used for uploaded artwork and thumbnails.
- ```/eccoserv/fanfiction``` Used for uploaded text documents.
- ```/eccoserv/mp3``` Used for uploaded music.
- ```/wiki``` Where all the editable pages on the website are stored.

# Setting Up config.pm (Optional)

### ROOT_PATH
```perl
$_config{ROOT_PATH}
```
 The absolute path of where the wiki's files are stored. It's currently set to automatically detect its location.
 
 ### DEVELOPERS_MODE
```perl
$_config{DEVELOPER_MODE} = 0
```
When set to 1 the wiki goes into developers mode. This tells the system to use localhost (127.0.0.1) instead of `$_config{WEB_HOST}`.

### WEB_HOST
```perl
$_config{WEB_HOST} = "enigma4.nexusultima.com";
```
The server this wiki is hosted on.

### CGI_BIN_PATH
```perl
$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";
```
Path where all the scripts are contained.

### CONTENT_PATH
```perl
$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";
```
Path where all the resources such as images and other data are contained.

### WIKI_PATH
```perl
$_config{WIKI_PATH} =  "$_config{ROOT_PATH}/wiki";
```
Path where all the pages on the website and their histories are stored.

### FLOOD_INTERVAL
```perl
$_config{FLOOD_INTERVAL} = 15;
```
Flood Interval used to prevent double posting on various parts of the system (such as comments).

### DEFCON
```perl
$_config{DEFCON} = 2;
```
Used to lock down the system into various states. Setting defcon to 2 locks down: file uploads and profile creation. Setting defcon to 3 locks down: file uploads.

# Locking Wiki Pages

All pages located in the `wiki` directory are the same pages that are hosted to the website. 
You can use `chmod 444` to prevent write access to them which the wiki system will detect.

# Banning Users

When a new page is created or edited an IP address is logged in an "editor stamp".
The editor stamp cannot be viewed when editing a page but is visible if you view the source code
for the page in the browser.

```html
<!-- editorstamp::192.168.0.3::20081031081136 -->
```

A file located in `cgi-bin/banned` is used to store all the IPs that are banned from
using the wiki. Banned users will still be able to view pages on the wiki.

# Known Issues
- Running any script from this system in the command line will create conflicting sessions with localhost (127.0.0.1). To fix this delete all session files (those ending with .sid) located in the directory set in `$_config{ROOT_PATH}`.
