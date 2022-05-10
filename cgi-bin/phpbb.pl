#!/usr/bin/perl -w

use strict;
use lib '/var/www/cgi-bin';
use Enigma::Core;
use CGI qw(:all);

sub ParsePhpBB {
	my $thread = '';
	
	my $data = Enigma::Core::FileRead("/phpbb.20021001");
	my @array = split(/\n/, $data);
	
	foreach (@array) {
		my @element = split(/,'/, $_);
		
		$element[3] =~s/\',1\);//g;
		$element[3] =~s/\\r\\n//g;
		$element[3] =~s/\\//g;
		$element[3] =~s/\\//g;
		$element[3] =~s/\[[^\]]+\]//g;
		$element[3] =~s/:[^:]+://g;
		
		$thread .= "<div id='container'>\n";
		$thread .= "$element[3]\n</div>\n<br />\n\n";
	}
	print header;
	print "<link href='../eccoserv/theme/crystalmeth-light.css' rel='stylesheet' type='text/css'>\n";
	print $thread;
}

ParsePhpBB;