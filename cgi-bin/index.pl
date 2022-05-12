#!/usr/bin/perl -w

use strict;

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use config;

Enigma::Core::SetConfig(config::Get);
Enigma::Core::Display;
