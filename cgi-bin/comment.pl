#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::CommentManager;
use CGI::Carp qw(fatalsToBrowser);

&Enigma::CommentManager::ModuleUpdate;