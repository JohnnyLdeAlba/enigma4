# Enigma 4 Beta

A perl based wiki made in 2008 that uses the file system as database storage.

# Features
- Anonymously create and edit pages without having to login to an account.
- Edit history allows users to see what changes were made to a page.
- Fanfare section allows anyone to create personal profiles with contact information and contributions to the website.
- An image gallery that generates thumbnails and inserts them into the users page of choice.
- Allows users to upload other contributions such as stories (in various text formats) and mp3s.
- Supports custom themes that allow users to change how the website looks.

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

# Setting Up config.pm File (Optional)

- `$_config{ROOT_PATH}` The absolute path of where the wiki's files are stored. It's currently set to automatically detect its location.
- `$_config{DEVELOPER_MODE} = 0` When set to 1 the wiki goes into developers mode. This tells the system to use localhost (127.0.0.1) instead of WEB_HOST.
- 
- `$_config{WEB_HOST} = "enigma4.nexusultima.com";` The server this wiki is hosted on.

- `$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";` Path where all the scripts are contained.
- `$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";` Path where all the resources such as images and other data are contained.
- `$_config{WIKI_PATH} =  "$_config{ROOT_PATH}/wiki";` Path where all the pages on the website and their histories are stored.
- `$_config{FLOOD_INTERVAL} = 15;` Flood Interval used to prevent double posting on various parts of the system (such as comments).
- `$_config{DEFCON} = 2;` Used to lock down the system into various states. Setting defcon to 2 locks down: file uploads and profile creation. Setting defcon to 3 locks down: file uploads.

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
