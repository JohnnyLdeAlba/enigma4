#!/usr/bin/perl -w

package Enigma::StoryManager;
use lib '/var/www/cgi-bin';

use strict;
use Switch;

use Enigma::Core2;
use CGI qw(:all);
use Image::Magick;

$CGI::POST_MAX = 1024 * 10000;

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

my $author_ucfirst;
my $author_uc;
my $author_lc;

my $title_ucfirst;
my $title_uc;
my $title_lc;

my $description;
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
	
	$author_ucfirst = '';
	$author_uc = '';
	$author_lc = '';

	$title_ucfirst = '';
	$title_uc = '';
	$title_lc = '';
	$description = '';
	
	return 1;
}

sub UploadDocument {
	$document_handle = param('document_handle');
	if ($document_handle eq '') {
	    # NO DOCUMENT SELECTED
		return -5;
	}

	my $type = uploadInfo($document_handle)->{'Content-Type'};
	if (($type eq 'text/plain')) {
		$type = 'txt'; }
	elsif (($type eq 'text/rtf')) {
		$type = 'rtf'; }
	elsif (($type eq 'text/html')) {
		$type = 'htm'; }
	elsif (($type eq 'application/msword')) {
		$type = 'doc'; }
	else {
		#FILE UPLOAD NOT TXT/RTF/DOC
		return -14;
	}
	
	$document_file = "$author_lc-$title_lc.$type";
	my $pathFile = "$pathBase$pathEccoServ/fanfiction/$document_file";
	
	open(HANDLE, ">$pathFile"); 
	while (<$document_handle>) { print HANDLE $_; }
	close(HANDLE);
	
	return 1;
}

sub Update2Section {
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki$fileSection");
	
	my $insert .= "<br /><br /><li>\n";
	$insert .= "<a href='../eccoserv/fanfiction/$document_file'\n";
	$insert .= "target='_blank'>$title_ucfirst</a> by $author_ucfirst\n";
	$insert .= "<br />$description\n";
	$insert .= "<!-- placeholder -->\n";
	
	$document =~s/<!-- placeholder -->\n/$insert/;
	$document =~s/<!-- editorstamp.*>\n//g;
	
	$document = &Enigma::Core2::EditorStamp().$document;
	if (&Enigma::Core2::FileArchive("$pathBase$pathPerl$pathWiki$fileSection")) {
		&Enigma::Core2::FileSave("$pathBase$pathPerl$pathWiki$fileSection", $document);
	}
	else {
		# FILE NOT WRITABLE
		return -7;
	}
	
	return 1;
}

sub Update2Forum {
	my $insert = &Enigma::Core2::TimeStamp.": Fan fiction added to the fanfare section: ";
	$insert.= "\[url=http://www.arkonviox.net/eccoserv/fanfiction/$document_file\]";
	$insert .="$document_file\[/url\]";
	$insert.= "<br />";
	
	&Enigma::Core2::Update2Forum($insert);
	return 1;
}

sub UpdateSection {
	($author_ucfirst, $title_ucfirst, $description, $securityphrase)
	= (param('author_ucfirst'), param('title_ucfirst'), param('description'), param('securityphrase'));
	
	$author_ucfirst = ucfirst($author_ucfirst);
	$author_uc = uc($author_ucfirst);
	$author_lc = lc($author_ucfirst);
	$author_lc =~s/ /\-/g;
	
	$title_ucfirst = ucfirst($title_ucfirst);
	$title_uc = uc($title_ucfirst);
	$title_lc = lc($title_ucfirst);
	$title_lc =~s/ /\-/g;
	
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core2::GetSession);
	
	if ($author_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -4;
	}
	
	if ($title_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -3;
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
	
	$errorCode = &UploadDocument;
	if ($errorCode ne 1) {
		return $errorCode;
	}
	
	$errorCode = &Update2Section;
	if ($errorCode ne 1) {
		return $errorCode;
	}
	
	&Update2Forum;

	$session{floodinterval} = &Enigma::Core2::TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	return 2;
}

sub Display {
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core2::GetSession);
	
	$session{securityphrase} = &Enigma::Core2::TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki/upload-story");
	$document =~s/{author_ucfirst}/$author_ucfirst/;
	$document =~s/{title_ucfirst}/$title_ucfirst/;
	$document =~s/{description}/$description/;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	return 1;
}

sub DisplayUpload {
	$errorMsg = &Enigma::Core2::GetErrorMessage($errorCode);
	
	if ($errorCode eq 2) {
		$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki$fileSection");
	}
	else {
		&Display;
	}
	
	if ($errorMsg ne '') {
		$errorMsg = "<h3>$errorMsg<\/h3><br \/>";
	}
	
	$document =~s/<!-- errormessage -->/$errorMsg/;
	return 1;
}

sub ModuleUpdate {
	&Initialize;
	
	my $func = param('func');
	if ($func eq 'upload') {
		$errorCode = &UpdateSection;
		&DisplayUpload;
	} else {
		&Display;
	}
	
	print header;
	&Enigma::Core2::TranslateTheme(\$document);
	print $document;
	return 1;
}

1;