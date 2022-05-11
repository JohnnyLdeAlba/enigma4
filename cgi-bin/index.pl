#!/usr/bin/perl -w

use strict;

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core2;
use config;

Enigma::Core2::ReadConfig(config::Get());
Enigma::Core2::Display;
