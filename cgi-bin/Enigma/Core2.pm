#!/usr/bin/perl -w

package Enigma::Core2;

use strict;
use Cwd 'abs_path';
use lib abs_path('.');

#use Image::Magick;
use Time::localtime;
use Digest::MD5 qw(md5);

use CGI qw(:all);

abs_path('.') =~ m/(.*)\//;
my $pathBase = "$&";


use Fcntl qw(:flock);

$CGI::POST_MAX = 1024 * 5000;

# Depricated
my $pathRoot = "";
sub GetPathRoot { return $pathRoot; }

my $pathPerl = '/cgi-bin';
my $pathEccoServ = '/eccoserv';
my $pathWiki = '/wiki';

my $fileBanned = "/banned.log";
my $fileDebug = "/debug.log";

my $fileFanArt = '/fan-artwork-2';
my $fileCetaArt = '/cetacean-artwork-2';
my $fileCrestArt = '/crestoes-artwork-1';
my $fileMacrosAvatars = '/macros-and-avatars-1';

my $floodInterval = 15;

sub GetPathBase { return $pathBase; }
sub GetPathPerl { return $pathPerl; }
sub GetPathEccoServ { return $pathEccoServ; }
sub GetPathWiki { return $pathWiki; }

sub GetFileBanned { return $fileBanned; }
sub GetFloodInterval { return $floodInterval; }

my %document; my %session; my %cookie;
my %global;
my $interval = 15;

my $errorCode; 
my $errorMsg;

my $article_ucfirst;
my $article_uc;
my $article_lc;
my $securityphrase;

sub FileRead {
	my $pathFile = shift;
	my $data;
	
	if (-e $pathFile) {
		open (HANDLE, "<$pathFile") or die;
		while (<HANDLE>) { $data.= $_; }
		close(HANDLE);
	}
	else {
		# FILE DOES NOT EXIST
		return -1;
	}
	
	return $data;
}

sub ProceedWithZero {
	my $array = \@_;

	my $element; my $count = 0;
	foreach $element (@$array) {
		if ($element < 10) { $$array[$count] = "0$element"; }
		$count++;
	}
	
	return @$array;
}

sub TimeStamp {
        my ($year, $mon, $mday, $hour, $min, $sec) = (localtime->year+1900, localtime->mon+1,
			localtime->mday, localtime->hour, localtime->min, localtime->sec);
		
		($mon, $mday, $hour, $min, $sec) = ProceedWithZero($mon, $mday, $hour, $min, $sec);
        return $year.$mon.$mday.$hour.$min.$sec;
}

sub DateStamp {
        my ($year, $mon, $mday) = (localtime->year+1900, localtime->mon+1, localtime->mday);
		
		($mon, $mday) = ProceedWithZero($mon, $mday);
        return $year.$mon.$mday;
}

sub FileSave {
	my ($pathFile, $data) = @_;
	
	if (-e $pathFile) {
		if (!(-w $pathFile)) {
			# FILE IS NOT WRITABLE
			return -1;
		}
	}
	
	open (HANDLE, ">$pathFile") or die;
	flock (HANDLE, LOCK_EX);
	print HANDLE $data;
	close (HANDLE);
	
	return 1;
}

sub FileArchive {
	my $pathFile = shift;
	my $timeStamp = &TimeStamp;
	
	if (-e $pathFile) {
		if (-w $pathFile) {
			open (HANDLE, "<$pathFile") or die;
			my @data = <HANDLE>;
			close(HANDLE);
		
			open (HANDLE, ">$pathFile.$timeStamp") or die;
			flock (HANDLE, LOCK_EX);
			print HANDLE @data;
			close (HANDLE);
		}
		else {
			# FILE NOT WRITABLE
			return -1
		}
	}
	
	return 1;
}

sub SetSession {
	my $args = shift;
	
	my $ip = remote_addr();
	my $date = &DateStamp;
	
	my $data = &FileRead("$pathBase/$date.sid");
	if ($data eq -1) {
		unlink("$pathBase/".($date-1).".sid");
		return &FileSave("$pathBase/$date.sid", "$ip:$args\n");
	}
	
	if ($data !~s/$ip:.*\n/$ip:$args\n/) {
		$data .= "$ip:$args\n";
	}
	
	&FileSave("$pathBase/$date.sid", $data);
	return 1;
}

sub GetSession {
	my $ip = remote_addr();
	my $date = &DateStamp;
	
	my $data = &FileRead("$pathBase/$date.sid");
	if ($data eq -1) {
		return 0;
	}
	
	if ($data =~m/$ip:(.*)\n/) {
		return $1;
	}
	
	return 0;
}

sub Update2Forum {
	my $data = FileRead("/server/arkonviox.net/cgi-bin/yabb2/Messages/1223525105.txt");
	my @array = split(/\|/, $data);
	
	$array[8] = $_[0].$array[8];
	
	$data = "$array[0]|$array[1]|$array[2]|$array[3]|$array[4]|$array[5]|";
	$data .= "$array[6]|$array[7]|$array[8]|$array[9]|$array[10]|$array[11]|";
	$data .= "$array[12]";
	
	FileSave("/server/arkonviox.net/cgi-bin/yabb2/Messages/1223525105.txt", $data);
}

sub Banned {
	my $data = &FileRead($pathBase.$pathPerl.$fileBanned);
	my @array = split(/\n/, $data);
	my $ip = remote_addr();
	
	my $element;
	foreach $element (@array) {
		if ($ip eq $element) { return 1; }
	}
	
	return 0;
}

sub EditorStamp {
	my $comment = shift;
	my $ip = remote_addr();
	my $timeStamp = &TimeStamp;
	
	return "<!-- editorstamp::".$ip."::"."$timeStamp -->\n";
}

sub GetErrorMessage {
	my $codeError = shift;
	my $msgError = '';
	
	if ($codeError eq '5') {
		$msgError = "Success: Your article has been saved.\n";
	}
	elsif ($codeError eq '4') {
		$msgError = "Success: Your profile has been submitted.\n";
	}
	elsif ($codeError eq '3') {
		$msgError = "Success: Your comment has been submitted.\n";
	}
	elsif ($codeError eq '2') {
		$msgError = "Success: Your file has been uploaded.\n";
	}
	elsif ($codeError eq '-1') {
		$msgError = "Error: You are banned from using Enigma.\n";
	}
	elsif ($codeError eq '-2') {
		$msgError = "Error: You must wait 15 seconds before you can post again.\n";
	}
	elsif ($codeError eq '-3') {
		$msgError = "Error: TITLE field can only contain letters, numbers and spaces.\n";
		$msgError.= "TITLE field can only begin and end with letters or numbers.\n";
	}
	elsif ($codeError eq '-4') {
		$msgError = "Error: AUTHOR field can only contain letters, numbers and spaces.\n";
		$msgError.= "AUTHOR field can only begin and end with letters or numbers.\n";
	}
	elsif ($codeError eq '-5') {
		$msgError = "Error: You must select a file to upload.\n";
	}
	elsif ($codeError eq '-6') {
		$msgError = "Error: File can only be of JPEG, GIF, PNG format.\n";
	}
	elsif ($codeError eq '-7') {
		$msgError = "Error: File cannot be saved because it is locked.\n";
	}
	elsif ($codeError eq '-8') {
		$msgError = "Error: The security phrase you entered was not valid.\n";
	}
	elsif ($codeError eq '-9') {
		$msgError = "Error: Bad HTTP Referral.\n";
	}
	elsif ($codeError eq '-10') {
		$msgError = "Error: ARTICLE field can only contain letters, numbers and spaces.\n";
		$msgError.= "ARTICLE field can only begin and end with letters or numbers.\n";
	}
	elsif ($codeError eq '-11') {
		$msgError = "Error: USERNAME field can only contain letters, numbers and spaces.\n";
		$msgError.= "USERNAME field can only begin and end with letters or numbers.\n";
	}
	elsif ($codeError eq '-12') {
		$msgError = "Notice: File cannot be saved because it has not been altered.\n";
	}
	elsif ($codeError eq '-13') {
		$msgError = "Notice: Requested article does not exist but a new\n";
		$msgError.= "article can be created by filling in the appropriate fields.\n";
	}
	elsif ($codeError eq '-14') {
		$msgError = "Error: File can only be of TXT, RTF, DOC format.\n";
	}
	elsif ($codeError eq '-15') {
		$msgError = "Error: Requested article does not exist.\n";
	}
	elsif ($codeError eq '-16') {
		$msgError = "Notice: There is currently no history for this article.\n";
	}
	elsif ($codeError eq '-17') {
		$msgError = "Error: You must select a section for the image upload.\n";
	}
	elsif ($codeError eq '-18') {
		$msgError = "Error: A file with that name already exists.\n";
	}
	elsif ($codeError eq '-19') {
		$msgError = "Notice: File successfully overwritten.\n";
	}
	elsif ($codeError eq '-20') {
		$msgError = "Error: File cannot be overwritten because it does not exist.\n";
	}
	elsif ($codeError eq '-21') {
		$msgError = "Error: File can only be MP3 format.\n";
	}
	
	return $msgError;
}

sub TranslateTheme {
	my $data = $_[0];
	my $default = 'defender';
	
	if ($$data !~/<!wiki func='wikitheme'/) {
		return 0;
	}

	my $theme = '';
	$theme = param('theme');
	if ($$data =~m/<!wiki func='wikitheme' theme='(.*)'>/) {
		$theme = $1;
	}
	else {
		if ($theme eq '') {
			$theme = cookie('WikiTheme');
			if ($theme eq '') {
				$theme = $default;
			}
		}
	}
	
	my $header; my $footer;
	$header = FileRead("$pathBase$pathPerl/theme/$theme-header.tpl");
	if ($header eq -1) {
		$header = FileRead("$pathBase$pathPerl/theme/$default-header.tpl");
		$footer = FileRead("$pathBase$pathPerl/theme/$default-footer.tpl");
	}
	else {
		$footer = FileRead($pathBase.$pathPerl."/theme/$theme-footer.tpl");
	}
	
	$$data =~s/<!wiki func='wikitheme' type='header'>/$header/;
	$$data =~s/<!wiki func='wikitheme' type='footer'>/$footer/;
	
	return 1;
}

sub UpdateWiki {
	$article_ucfirst = param('article_ucfirst');
	$document{content} = param('content');
	$securityphrase = param('securityphrase');
	
	$article_ucfirst = ucfirst($article_ucfirst);
	$article_uc = uc($article_ucfirst);
	$article_lc = lc($article_ucfirst);
	$article_lc =~s/ /\-/g;
	
	if ($article_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -10;
	}
	
	if (&Banned) {
		# IP BANNED
		return -1;
	}
	
	if (((&TimeStamp)-$session{floodinterval}) < $floodInterval) {
		# FLOOD INTERVAL HAS NOT TIMED OUT
		return -2;
	}
	
	if ($securityphrase ne $session{securityphrase}) {
		# INVALID SECURITY PHRASE
		return -8;
	}
	
	my $data = &FileRead("$pathBase$pathPerl$pathWiki/$article_lc");
	
	$document{content} =~s/\r\n|\r/\n/g;
	$data =~s/<!-- editorstamp.*>\n//g;
	
	if (md5($document{content}) eq md5($data)) {
		# FILE CHECKSUM MATCH
		return -12;
	}
	
	$document{content} = &EditorStamp.$document{content};
	if (FileArchive("$pathBase$pathPerl$pathWiki/$article_lc") eq -1) {
		# FILE LOCKED
		return -7;
	}
	
	FileSave("$pathBase$pathPerl$pathWiki/$article_lc", $document{content});
	$session{floodinterval} = &TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	return 5;
}

sub DisplayEdit {
	my $id = param('id');
	my $func = param('func');
	
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &GetSession);
	
	if ($func eq 'update') {
		$errorCode = &UpdateWiki;
	}
	else {
		$article_ucfirst = ucfirst($id);
		$article_ucfirst =~s/\-/ /g;
		$article_uc = uc($article_ucfirst);
		$article_lc = lc($article_ucfirst);
		$article_lc =~s/ /\-/g;
		
		if ($article_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9.-]+[A-Za-z0-9]$/) {
			# INVALID CHARACTERS
			$errorCode = -10;
		}
		
		$document{content} = &FileRead("$pathBase$pathPerl$pathWiki/$article_lc");
		if ($document{content} eq -1) {
			# FILE DOES NOT EXIST
			$document{content} = '';
			$errorCode = -13;
		}
		
		if (-w "$pathBase$pathPerl$pathWiki/$article_lc") {
			$errorCode = 1;
		}
		else {
			# FILE IS NOT WRITABLE
			$errorCode = -7;
		}
	}
	
	$errorMsg = &Enigma::Core2::GetErrorMessage($errorCode);
	if ($errorMsg ne '') {
		$errorMsg = "<h3>$errorMsg<\/h3>";
	}
	
	$document{content} =~s/\r\n|\r/\n/g;
	$document{content} =~s/<!-- editorstamp.*>\n//g;
	
	$document{content} =~s/</&lt;/g;
	$document{content} =~s/>/&gt;/g;
	$document{content} =~s/{/&#123;/g;
	$document{content} =~s/}/&#125;/g;

	$session{securityphrase} = &Enigma::Core2::TimeStamp;
	&Enigma::Core2::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	my $data = FileRead("$pathBase$pathPerl$pathWiki/edit");
	$data =~s/{article_ucfirst}/$article_ucfirst/g;
	$data =~s/{article_lc}/$article_lc/g;
	$data =~s/{content}/$document{content}/;
	$data =~s/{securityphrase}/$session{securityphrase}/;
	$data =~s/<!-- errormessage -->/$errorMsg/;
	
	print header;
	&TranslateTheme(\$data);
	print $data;
	
	return 1;
}

sub DisplayHistory {
	$errorCode = 1;
	
	my $id = param('id');
	$article_ucfirst = ucfirst($id);
	$article_ucfirst =~s/\-/ /g;
	$article_uc = uc($article_ucfirst);
	$article_lc = lc($article_ucfirst);
	$article_lc =~s/ /\-/g;
	
	my $insert = '';
	if ($article_lc !~/^[A-Za-z0-9][A-Za-z0-9.-]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		$errorCode =  -10;
	}
	else {
		my $pathFile = "/$article_lc";
		
		if (-e "$pathBase$pathPerl$pathWiki$pathFile") {
			my @directory = glob("$pathBase$pathPerl$pathWiki$pathFile.*");
			my $element;
			
			if (defined($directory[0])) {
			
				foreach $element (@directory) {
					$element =~/\/([A-Za-z0-9.-]+$)/;
					$element = $1;
					
					$insert .= "[ <a href='edit.pl?id=$element' target='_blank'>Edit</a> ] ";
					$insert .= "[ <a href='display.pl?id=$element' target='_blank'>Display</a> ] ";
					$insert .= "$element\n";
					$insert .= "<br />\n";
				}
			}
			else  { $errorCode = -16 }
		}
		else { $errorCode = -15 }
	}
	
	$document{content} = &FileRead("$pathBase$pathPerl$pathWiki/history");
	$document{content} =~s/{article_ucfirst}/$article_ucfirst/g;
	$document{content} =~s/{article_uc}/$article_uc/g;
	$document{content} =~s/{article_lc}/$article_lc/g;
	
	$errorMsg = &GetErrorMessage($errorCode);
	if ($errorCode eq 1) {
		$document{content} =~s/{placeholder}/$insert/; }
	else {
		$document{content} =~s/{placeholder}/<h3>$errorMsg<\/h3>/; }
	
	print header;
	&TranslateTheme(\$document{content});
	print $document{content};
	
	return 1;
}

sub Display {
	$document{article} = param('id');
	
	if ($document{article} !~/^[A-Za-z0-9][A-Za-z0-9.-]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		$document{article} = 'index';
	}
	
	$document{content} = FileRead($pathBase.$pathPerl.$pathWiki."/$document{article}");
	if ($document{content} eq -1) {
		$document{content} = FileRead($pathBase.$pathPerl.$pathWiki."/index");
	}
	
	$document{content} =~s/\[<\]/&lt;/g;
	$document{content} =~s/\[>\]/&gt;/g;
	$document{content} =~s/\[&\]/&amp;/g;
	$document{content} =~s/\[&\]/&amp;/g;
		
	my $theme = param('theme');
	if ($theme ne '') {
		$cookie{header} = cookie(-name => 'WikiTheme', -value => $theme, -expires => '+1y');
		print header(-cookie => $cookie{header});
	}
	else {
		print header;
	}
		
	&TranslateTheme(\$document{content});
	print $document{content};
}

1;
