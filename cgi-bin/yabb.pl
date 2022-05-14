#!/usr/bin/perl -w

use strict;
use CGI qw(:all);

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use config;

Enigma::Core::SetConfig(config::Get);

my $pathYabb = 'yabb';

sub YabbIndex {
	my $data = Enigma::Core::FileRead("$pathYabb/index.txt");
	my @array = split(/\n/, $data);
	
	my $content = "<table cellpadding='0' cellspacing='5' width='95%'>\n";
	foreach (@array) {
		my @document = split(/\|/, $_);

		$content .= "<tr>\n";
		$content .= "<td align='left' valign='top' width='75%'>\n";
		$content .= "<a href='yabb.pl?id=$document[0]'>$document[1]</a>\n";
		$content .= "<td align='left' valign='top' width='25%'>\n";
		$content .= "$document[2]\n";
	}
	$content .= "</table>\n";
	
	$data = Enigma::Core::FileRead("yabbindex.tpl");
	$data =~s/{content}/$content/;
	
	print header;
	print $data;
}


sub YabbThread {
	my $id = shift @_;
	
	my $data = Enigma::Core::FileRead("$pathYabb/$id.txt");
	my @array = split(/\n/, $data);
	
	my @document = split(/\|/, (shift @array));
	my $topic = "<h1>$document[0]</h1>\n";
	$topic .= "<h2>by <a href='email:$document[2]'>$document[1]</a> at $document[3]</h2>\n";
	$topic .= "<p>$document[8]</p>";
	
	my $content = '';
	foreach (@array) {
		@document = split(/\|/, $_);
		
		$content .= "<span id='tab'><a href='email:$document[2]'>$document[1]</a></span>\n";
		$content .= "<div id='thread'>\n";
		$content .= "<h1>$document[3]</h1>\n";
		$content .= "$document[8]\n</div>\n<br />\n\n";
	}
	
	$data = Enigma::Core::FileRead("yabbthread.tpl");
	$data =~s/{topic}/$topic/;
	$data =~s/{content}/$content/;
	
	print header;
	print $data;
}

sub Run {
	my $id = param('id');

	if (defined($id)) {
		YabbThread($id);
	}
	else {
		YabbIndex;
	}
}

Run;
