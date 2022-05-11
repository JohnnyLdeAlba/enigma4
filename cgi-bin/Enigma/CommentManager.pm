#!/usr/bin/perl -w

package Enigma::CommentManager;
use lib '/var/www/cgi-bin';

use strict;
use Switch;

use Enigma::Core2;
use CGI qw(:all);
#use Image::Magick;

my $document;
my %session;

my $errorCode; 
my $errorMsg;

my $pathBase;
my $pathPerl;
my $pathEccoServ;
my $pathWiki;

my $fileSection = '/fan-fiction-2';

my $floodinterval;

my $document_file;
my $document_handle;

my $id;
my $author_ucfirst;
my $author_uc;
my $author_lc;

my $topic;
my $comment;
my $securityphrase;

sub Initialize {
	$pathBase = &Enigma::Core2::GetPathBase;
	$pathPerl = &Enigma::Core2::GetPathPerl;
	$pathEccoServ = &Enigma::Core2::GetPathEccoServ;
	$pathWiki = &Enigma::Core2::GetPathWiki;
	$floodinterval = &Enigma::Core2::GetFloodInterval;
	
	$document = '';
	$errorCode = 0; 
	$errorMsg = '';
	
	$id = '';
	$author_ucfirst = '';
	$author_uc = '';
	$author_lc = '';
	
	$topic = '';
	$comment = '';
	
	return 1;
}

sub Update2Section {
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki/$id");
	
	my $insert = "<div style='text-align:left;' id='key'>\n";
	$insert .= "<div>$author_ucfirst, said:</div>\n";
	$insert .= "<div style='margin:1px 0px 1px 0px;'>\n";
	$insert .= "<p>\n$comment</p>\n";
	$insert .= "</div>\n";
	$insert .= "<div>&nbsp;</div>\n";
	$insert .= "</div><br />\n";
	$insert .= "<!-- placeholder::comment -->\n";
	
	$document =~s/<!-- placeholder::comment -->\n/$insert/;
	$document =~s/<!-- editorstamp.*>\n//g;
	$document = &Enigma::Core2::EditorStamp.$document;
	
	if (&Enigma::Core2::FileArchive("$pathBase$pathPerl$pathWiki/$id")) {
		&Enigma::Core2::FileSave("$pathBase$pathPerl$pathWiki/$id", $document);
	}
	else {
		# FILE NOT WRITABLE
		return -7;
	}
	
	return 1;
}

sub UpdateSection {
	($author_ucfirst, $comment, $securityphrase)
	= (param('author_ucfirst'), param('comment'), param('securityphrase'));
	
	$author_ucfirst = ucfirst($author_ucfirst);
	$author_uc = uc($author_ucfirst);
	$author_lc = lc($author_ucfirst);
	$author_lc =~s/ /\-/;
	
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core2::GetSession);
	
	if ($author_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -4;
	}
	
	if ($ENV{'HTTP_REFERER'} !~/arkonviox\.net\/cgi-bin\/comment\.pl/) {
		if ($ENV{'HTTP_REFERER'} !~/arkonviox\.net\/perl\/comment\.pl/) {
			# BAD HTTP REFERER
			return -9;
		}
	}
	
	if (&Enigma::Core2::Banned) {
		# IP BANNED
		return -1;
	}
	
	if (((&Enigma::Core2::TimeStamp)-$session{floodinterval}) < $floodinterval) {
		# FLOOD INTERVAL HAS NOT TIMED OUT
		return -2;
	}
	
	if ($securityphrase ne $session{securityphrase}) {
		# INVALID SECURITY PHRASE
		return -8;
	}
	
	$errorCode = &Update2Section;
	if ($errorCode ne 1) {
		return $errorCode;
	}

	$session{floodinterval} = &Enigma::Core2::TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	return 3;
}

sub Display {
	$errorMsg = &Enigma::Core2::GetErrorMessage($errorCode);
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core2::GetSession);
	
	$session{securityphrase} = &Enigma::Core2::TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	$comment =~s/</&lt;/g;
	$comment=~s/>/&gt;/g;
	$comment =~s/['"]/&#39;/g;
	
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki/$id");
	$document =~s/{id}/$id/;
	$document =~s/{author_ucfirst}/$author_ucfirst/;
	$document =~s/{comment}/$comment/;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	if ($errorMsg ne '') {
		$errorMsg = "<h3>$errorMsg<\/h3><br \/>";
	}
	
	$document =~s/<!-- errormessage::comment -->/$errorMsg/;
	print header;
	&Enigma::Core2::TranslateTheme(\$document);
	print $document;
	
	return 1;
}

sub ModuleUpdate {
	&Initialize;
	
	$id = param('id'); $id = lc($id); $id =~s/ /\-/;
	
	my $func = param('func');
	if ($func eq 'create') {
		$errorCode = &UpdateSection;
	} 
	
	&Display;
	return 1;
}

1;
