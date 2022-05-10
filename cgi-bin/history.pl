#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::Core2;
use CGI qw(:all);

Enigma::Core2::DisplayHistory;