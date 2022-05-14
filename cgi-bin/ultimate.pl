#!/usr/bin/perl -w

use strict;
use CGI qw(:all);

use Cwd qw(abs_path);
use lib abs_path('.');

use Enigma::Core;
use config;

Enigma::Core::SetConfig(config::Get);

my $pathUbb = 'ubb';

sub ParseIndex {
	my $data = Enigma::Core::FileRead("$pathUbb/index.ubb");
	my @array = split(/\n/, $data);
	
	my $thread = '';
	foreach (@array) {
		my @document = split(/\|\|/, $_);

		$thread .= "<tr>\n";
		$thread .= "<td align='left' valign='top' width='75%'>\n";
		$thread .= "<a href='ultimate.pl?id=$document[1]'>$document[3]</a>\n";
		$thread .= "<td align='left' valign='top' width='25%'>\n";
		$thread .= "$document[2]\n";
	}
	
	print header;
        print "<div style='margin: 16px auto; width: 800px;'>\n";
	print "<link href='../eccoserv/theme/the-undercaves.css' rel='stylesheet' type='text/css'>\n";
	
	print "<span id='tab'>The Undercaves Ubb Forum</span>\n";
	print "<div id='container'>\n";
	print "<h1>The Undercaves 2000 to 2001 Ubb Forum Archive</h1>\n";
	print "<br /><br />\n";
	
	print "<span id='tab'>Thread Directory</span>\n";
	print "<div id='panel'>\n";
	print"<table cellspacing='5' cellpadding='0' width='100%'>\n";
	print "<tr>\n";
	print "<td align='left' valign='top' width='75%'>\n";
	print "<b>Topic</b>\n";
	print "<td align='left' valign='top' width='25%'>\n";
	print "<b>Posted By</b>\n";
	print $thread;
	
	print "</table>\n";
	print "</div>\n";
	
	print "</div>\n";
        print "</div>\n";
}


sub ParseUbb {
	my $id = shift @_;
	
	my $data = Enigma::Core::FileRead("$pathUbb/$id.ubb");
	my @array = split(/\n/, $data);
	
	my @document = split(/\|\|/, (shift @array));
	my $topic = $document[4];
	
	my $thread = '';
	foreach (@array) {
		@document = split(/\|\|/, $_);
		$document[6] =~s/<IMG [^>]*>//g;
		
		$thread .= "<span id='tab'><a href='email:$document[5]'>$document[2]</a></span>\n";
		$thread .= "<div id='thread'>\n";
		$thread .= "<h1>$document[3] $document[4]</h1>\n";
		$thread .= "$document[6]\n</div>\n<br />\n\n";
	}
	
	print header;
        print "<div style='margin: 16px auto; width: 800px;'>\n";
	print "<link href='../eccoserv/theme/the-undercaves.css' rel='stylesheet' type='text/css'>\n";
	
	print "<span id='visited'><a href='ultimate.pl'>";
	print "The Undercaves Ubb Forum</a></span>&nbsp;\n";
	print "<span id='tab'>$id</span>\n";
	
	print "<div id='container'>\n";
	print "<h1>$topic</h1>\n";
	print "<br /><br />\n";
	print $thread;
	print "</div>\n";
	print "</div>\n";
}

sub Run {
	my $id = param('id');

	if (defined($id)) {
		ParseUbb($id);
	}
	else {
		ParseIndex;
	}
}

Run;
