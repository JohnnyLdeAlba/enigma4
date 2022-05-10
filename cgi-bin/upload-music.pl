#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::MusicManager;
use CGI::Carp qw(fatalsToBrowser);

&Enigma::MusicManager::ModuleUpdate;