#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::ProfileManager;
use CGI::Carp qw(fatalsToBrowser);

&Enigma::ProfileManager::Display;