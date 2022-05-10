#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::GalleryManager;
use CGI::Carp qw(fatalsToBrowser);

&Enigma::GalleryManager::ModuleUpdate;