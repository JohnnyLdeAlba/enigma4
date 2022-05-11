package config;

use strict;

use Cwd qw(abs_path);

my %_config = (

  DEVELOPER_MODE => 0,
  WEB_HOST => "",

  ROOT_PATH => "",
  CGI_BIN_PATH => "",
  CONTENT_PATH => "",
  WIKI_PATH => "",
  
  BANNED_FILE => "",
  DEBUG_FILE => "",

  FLOOD_INTERVAL => 0
);

abs_path('.') =~ m/(.*)\//;
$_config{ROOT_PATH} = $1;

$_config{DEVELOPER_MODE} = 1;
$_config{WEB_HOST} = "enigma4.nexusultima.com";

$_config{CGI_BIN_PATH} =  "$_config{ROOT_PATH}/cgi-bin";
$_config{CONTENT_PATH} =  "$_config{ROOT_PATH}/eccoserv";
$_config{WIKI_PATH} =  "$_config{ROOT_PATH}/wiki";
$_config{FLOOD_INTERVAL} = 15;

if ($_config{DEVELOPER_MODE} eq 1) {
  $_config{WEB_HOST} = "127.0.0.1"; 
}

sub Get { return %_config; }

1;
