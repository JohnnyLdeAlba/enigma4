#!/usr/bin/perl -w

use strict;
use CGI::Carp qw(fatalsToBrowser);

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use Enigma::ProfileManager;
use config;

Enigma::Core::SetConfig(config::Get);
Enigma::ProfileManager::Display;
