#!/usr/bin/perl -w

package Enigma::GalleryManager;
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
my $fileUpdate;

my $floodinterval;

my $image_file;
my $image_thumb;
my $image_handle;
my $overwrite;

my $author_ucfirst;
my $author_uc;
my $author_lc;

my $title_ucfirst;
my $title_uc;
my $title_lc;

my $section;
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
	
	$section = '';
	
	return 1;
}

sub UploadImage {
	$image_handle = param('image_handle');
	if ($image_handle eq '') {
	    # NO ARTWORK SELECTED
		return -5;
	}

	my $type = uploadInfo($image_handle)->{'Content-Type'};
	if (($type eq 'image/jpeg') or ($type eq 'image/pjpeg')) {
		$type = 'jpg';
	}
	elsif ($type eq 'image/gif') {
		$type = 'gif'; }
	elsif ($type eq 'image/png') {
		$type = 'png'; }
	else {
		#FILE UPLOAD NOT JPEG/PNG/GIF
		return -6;
	}
	
	$image_file = "$author_lc-$title_lc.$type";
	my $pathFile = "$pathBase$pathEccoServ/artwork/$image_file";
	
	if (-e $pathFile) {
		if ($section ne 'overwrite') {
			#FILE ALREADY EXISTS
			return -18;
		}
	} else {
		if ($section eq 'overwrite') {
			#OVERWRITE NOT SUCCESS
			return -20;
		}
	}
	
	open(HANDLE, ">$pathFile"); 
	while (<$image_handle>) { print HANDLE $_; }
	close(HANDLE);
		
	my $image = new Image::Magick;
	$image->Read($pathFile);
	my ($width, $height) = $image->Get('width', 'height');
	
	my $quotient;
	if (($width > 100) or ($height > 100)) {
		if ($width > $height) {
			$quotient = $width/100;
			$height = $height/$quotient;
			$width = 100;
		}
		else {
			$quotient = $height/100;
			$width = $width/$quotient;
			$height = 100;
		}
	}
	
	$image_thumb = "$author_lc-$title_lc"."x100.$type";
	my $pathFile = "$pathBase$pathEccoServ/artwork/$image_thumb";
	$image->Scale(width=>$width, height=>$height);
	$image->Write($pathFile);
	
	undef $image;
	
	if ($section eq 'overwrite') {
		#OVERWRITE SUCCESS
		return -19;
	}
	
	return 1;
}

sub Update2Section {
	if ($section eq '') {
		# NO SECTION  SELECTED
		return -17;
	}
	
	$fileUpdate = "/$section";
	my $count = 0; my $insert = '';
	
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki$fileUpdate");
	if ($document =~m/<!-- placeholder::([0-9]*) -->/) {
		$count = $1;
		if (($count%4) eq 0) {
			$insert = "<tr>\n";
		}
		$count++;
	}
	
	$insert .= "<td align='center' valign='bottom'>\n";
	$insert .= "<a href='../eccoserv/artwork/$image_file' target='_blank'>\n";
	$insert .= "<img src='../eccoserv/artwork/$image_thumb' border='0' /></a>\n";
	$insert .= "<br />$title_ucfirst by $author_ucfirst\n";
	$insert .= "<!-- placeholder::".$count." -->\n";
	
	$document =~s/<!-- placeholder.*>\n/$insert/;
	$document =~s/<!-- editorstamp.*>\n//g;
	
	$document = &Enigma::Core2::EditorStamp().$document;
	if (&Enigma::Core2::FileArchive("$pathBase$pathPerl$pathWiki$fileUpdate")) {
		&Enigma::Core2::FileSave("$pathBase$pathPerl$pathWiki$fileUpdate", $document);
	}
	else {
		# FILE NOT WRITABLE
		return -7;
	}
	
	return 1;
}

sub Update2Forum {
	my $section_ucfirst = ucfirst($section);
	$section_ucfirst =~s/\-/ /g;
	
	my $insert = &Enigma::Core2::TimeStamp.": Image added to the $section_ucfirst section: ";
	$insert.= "\[url=http://www.arkonviox.net/eccoserv/artwork/$image_file\]";
	$insert .="$image_file\[/url\]";
	$insert.= "<br />";
	
	&Enigma::Core2::Update2Forum($insert);
	return 1;
}

sub UpdateGallery {
	($author_ucfirst, $title_ucfirst, $section, $securityphrase)
	= (param('author_ucfirst'), param('title_ucfirst'), param('section'), param('securityphrase'));
	
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
	
	$errorCode = &UploadImage;
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
	
	$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki/upload-image");
	$document =~s/{author_ucfirst}/$author_ucfirst/;
	$document =~s/{title_ucfirst}/$title_ucfirst/;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	$document =~s/ {section::$section}/ selected/;
	$document =~s/ {section::.*}//g;
	
	return 1;
}

sub DisplayUpload {
	$errorMsg = &Enigma::Core2::GetErrorMessage($errorCode);
	
	if ($errorCode eq 2) {
		$document = &Enigma::Core2::FileRead("$pathBase$pathPerl$pathWiki$fileUpdate");
		
		if ($section = 'overwrite') {
			$document =~s/{author_ucfirst}/$author_ucfirst/;
			$document =~s/{title_ucfirst}/$title_ucfirst/;
			$document =~s/{securityphrase}/$session{securityphrase}/;
			
			$document =~s/ {section::$section}/ selected/;
			$document =~s/ {section::.*}//g;
		}
	}
	else {
		&Display;
	}
	
	if ($errorMsg ne '') {
		$errorMsg = "<h3>$errorMsg<\/h3>";
	}
	
	$document =~s/<!-- errormessage -->/$errorMsg/;
	return 1;
}

sub ModuleUpdate {
	&Initialize;
	
	my $func = param('func');
	if ($func eq 'upload') {
		$errorCode = &UpdateGallery;
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