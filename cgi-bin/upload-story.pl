#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::StoryManager;
use CGI::Carp qw(fatalsToBrowser);

&Enigma::StoryManager::ModuleUpdate;