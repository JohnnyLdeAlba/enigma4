#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::Core2;
use CGI qw(:all);
use CGI::Carp qw(fatalsToBrowser);

Enigma::Core2::Display;