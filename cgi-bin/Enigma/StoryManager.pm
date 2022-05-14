#!/usr/bin/perl -w

package Enigma::StoryManager;
use strict;

use Cwd 'abs_path';

abs_path('.') =~ m/(.*)\//;
use lib abs_path($&);

use Enigma::Core;
use CGI qw(:all);
use Image::Magick;

$CGI::POST_MAX = 1024 * 10000;

my %config;
my $document;
my %session;

my $errorCode; 
my $errorMsg;

my $fileSection = '/fan-fiction-2';

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
	
        %config = Enigma::Core::GetConfig();

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
	my $pathFile = "$config{CONTENT_PATH}/fanfiction/$document_file";
	
	open(HANDLE, ">$pathFile"); 
	while (<$document_handle>) { print HANDLE $_; }
	close(HANDLE);
	
	return 1;
}

sub Update2Section {
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}$fileSection");
	
	my $insert .= "<br /><br /><li>\n";
	$insert .= "<a href='../eccoserv/fanfiction/$document_file'\n";
	$insert .= "target='_blank'>$title_ucfirst</a> by $author_ucfirst\n";
	$insert .= "<br />$description\n";
	$insert .= "<!-- placeholder -->\n";
	
	$document =~s/<!-- placeholder -->\n/$insert/;
	$document =~s/<!-- editorstamp.*>\n//g;
	
	$document = &Enigma::Core::EditorStamp().$document;
	if (&Enigma::Core::FileArchive("$config{WIKI_PATH}$fileSection")) {
		&Enigma::Core::FileSave("$config{WIKI_PATH}$fileSection", $document);
	}
	else {
		# FILE NOT WRITABLE
		return -7;
	}
	
	return 1;
}

sub Update2Forum {
	my $insert = &Enigma::Core::TimeStamp.": Fan fiction added to the fanfare section: ";
	$insert.= "\[url=http://www.arkonviox.net/eccoserv/fanfiction/$document_file\]";
	$insert .="$document_file\[/url\]";
	$insert.= "<br />";
	
	&Enigma::Core::Update2Forum($insert);
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

        if ($config{DEFCON} le 3) {
          return -997;
        }
	
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	if ($author_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -4;
	}
	
	if ($title_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -3;
	}
	
	if (&Enigma::Core::Banned) {
		# IP BANNED
		return -1;
	}
	
	if (((&Enigma::Core::TimeStamp)-$session{floodinterval}) < $config{FLOOD_INTERVAL}) {
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

	$session{floodinterval} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	return 2;
}

sub Display {
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	$session{securityphrase} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/upload-story");
	$document =~s/{author_ucfirst}/$author_ucfirst/;
	$document =~s/{title_ucfirst}/$title_ucfirst/;
	$document =~s/{description}/$description/;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	return 1;
}

sub DisplayUpload {
	$errorMsg = &Enigma::Core::GetErrorMessage($errorCode);
	
	if ($errorCode eq 2) {
		$document = &Enigma::Core::FileRead("$config{WIKI_PATH}$fileSection");
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
	&Enigma::Core::TranslateTheme(\$document);
	print $document;
	return 1;
}

1;
