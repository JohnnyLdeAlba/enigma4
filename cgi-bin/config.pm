package config;

use strict;

use Cwd qw(abs_path);

my %_config = (

  ROOT_PATH => "",
  CGI_BIN_PATH => "",
  CONTENT_PATH => "",
  WIKI_PATH => "",
  
  BANNED_FILE => "",
  DEBUG_FILE => "",

  FLOOD_INTERVAL => 15
);

abs_path('.') =~ m/(.*)\//;

$_config{ROOT_PATH} = $1;

$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";
$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";
$_config{WIKI_PATH} =  "$_config{CGI_BIN_PATH}/wiki";

sub Get { return %_config; }

1;
