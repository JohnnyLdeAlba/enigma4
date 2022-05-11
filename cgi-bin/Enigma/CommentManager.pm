#!/usr/bin/perl -w

package Enigma::CommentManager;
use lib '/var/www/cgi-bin';

use strict;

use Enigma::Core;
use CGI qw(:all);
#use Image::Magick;

my %config;

my $document;
my %session;

my $errorCode; 
my $errorMsg;

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

        %config = Enigma::Core::GetConfig();

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
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/$id");
	
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
	$document = &Enigma::Core::EditorStamp.$document;
	
	if (&Enigma::Core::FileArchive("$config{WIKI_PATH}/$id")) {
		&Enigma::Core::FileSave("$config{WIKI_PATH}/$id", $document);
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
	
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	if ($author_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -4;
	}
	
	if ($ENV{'HTTP_REFERER'} !~ /^https?:\/\/$config{WEB_HOST}.+/) {
		# BAD HTTP REFERER
		return -9;
	}
	
	if (&Enigma::Core::Banned) {
		# IP BANNED
		return -1;
	}
	
	if (((&Enigma::Core::TimeStamp)-$session{floodinterval}) < $floodinterval) {
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

	$session{floodinterval} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	return 3;
}

sub Display {

	$errorMsg = &Enigma::Core::GetErrorMessage($errorCode);
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	$session{securityphrase} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	$comment =~s/</&lt;/g;
	$comment=~s/>/&gt;/g;
	$comment =~s/['"]/&#39;/g;
	
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/$id");
	$document =~s/{id}/$id/;
	$document =~s/{author_ucfirst}/$author_ucfirst/;
	$document =~s/{comment}/$comment/;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	if ($errorMsg ne '') {
		$errorMsg = "<h3>$errorMsg<\/h3><br \/>";
	}
	
	$document =~s/<!-- errormessage::comment -->/$errorMsg/;
	print header;
	&Enigma::Core::TranslateTheme(\$document);
	print $document;

	return 1;
}

sub ModuleUpdate {

	Initialize;
	
	$id = param('id'); $id = lc($id); $id =~s/ /\-/;
	
	my $func = param('func');
	if ($func eq 'create') {
		$errorCode = &UpdateSection;
	} 
	
	&Display;
	return 1;
}

1;
