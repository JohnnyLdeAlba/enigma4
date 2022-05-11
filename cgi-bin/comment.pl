#!/usr/bin/perl -w

use strict;

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use Enigma::CommentManager;
use config;

Enigma::Core::SetConfig(config::Get);
Enigma::CommentManager::ModuleUpdate;
