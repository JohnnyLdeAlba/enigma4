#!/usr/bin/perl -w

use strict;
use CGI qw(:all);

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use Enigma::CommentManager;
use config;

Enigma::Core::SetConfig(config::Get);
Enigma::Core::DisplayHistory;
