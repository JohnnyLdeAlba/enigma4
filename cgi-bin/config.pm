package config;

use strict;

use Cwd qw(abs_path);

my %_config = (

  PATH_ROOT => "",
  PATH_CGI_BIN => "",
  PATH_CONTENT => "",
  PATH_WIKI => "",
  
  FILE_BANNED => "",
  FILE_DEBUG => "",

  FLOOD_INTERVAL => 15
);

abs_path('.') =~ m/(.*)\//;

$_config{PATH_ROOT} = $1;

$_config{PATH_CGI_BIN} =  "$_config{PATH_ROOT}/cgi-bin";
$_config{PATH_CONTENT} =  "$_config{PATH_ROOT}/eccoserv";
$_config{PATH_WIKI} =  "$_config{PATH_CGI_BIN}/wiki";

sub Get { return %_config; }

1;
