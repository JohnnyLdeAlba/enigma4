#!/usr/bin/perl -w

package Enigma::ProfileManager;
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

my $existinguser;

my $avatar_file;
my $avatar_handle;

my $username_ucfirst;
my $username_uc;
my $username_lc;

my $realname;
my $email;
my $website;

my $messanger1; 
my $messanger2;
my $screenname1; 
my $screenname2;

my $sex; 
my $birth;
my $city; 
my $state; 
my $country;

my $operatingsystem; 
my $favoriteplatform; 
my $favoritegame;
my $interests; 
my $aboutmyself; 
my $securityphrase;

sub Initialize {

        %config = Enigma::Core::GetConfig();
	
	$document = '';
	$errorCode = 0; 
	$errorMsg = '';
	$existinguser = 0;

	$avatar_file = '';
	$avatar_handle = '';

	$username_ucfirst = '';
	$username_uc = '';
	$username_lc = '';

	$realname = '';
	$email = '';
	$website = '';

	$messanger1 = '';
	$messanger2 = '';
	$screenname1 = '';
	$screenname2 = '';

	$sex = '';
	$birth = '';
	$city = '';
	$state = '';
	$country = '';

	$operatingsystem = '';
	$favoriteplatform = '';
	$favoritegame = '';
	$interests = '';
	$aboutmyself = '';
	$securityphrase = '';
	
	return 1;
}

sub GetParameters {
	$avatar_file = param('avatar_file');
	$avatar_handle = param('avatar_handle');
	$username_ucfirst = param('username_ucfirst');
	$realname = param('realname');
	$email = param('email');
	$website = param('website');
	
	$messanger1 = param('messanger1');
	$messanger2 = param('messanger2');
	$screenname1 = param('screenname1');
	$screenname2 = param('screenname2');
	
	$sex = param('sex');
	$birth = param('birth');
	$city = param('city');
	$state = param('state');
	$country = param('country');
	
	$operatingsystem = param('operatingsystem');
	$favoriteplatform = param('favoriteplatform');
	$favoritegame = param('favoritegame');
	
	$interests = param('interests');
	$aboutmyself = param('aboutmyself');
	$securityphrase = param('securityphrase');
	
	return 1;
}

sub ParseParameters {
	$avatar_file =~s/[\n\r\|]//g;
	$username_ucfirst =~s/[\n\r\|]//g;
	$realname =~s/[\n\r\|]//g;
	$email =~s/[\n\r\|]//g;
	$website =~s/[\n\r\|]//g;
	
	$messanger1 =~s/[\n\r\|]//g;
	$messanger2 =~s/[\n\r\|]//g;
	$screenname1 =~s/[\n\r\|]//g;
	$screenname2 =~s/[\n\r\|]//g;
	
	$sex =~s/\[\n\r\|]//g;
	$birth =~s/\[\n\r\|]//g;
	$city =~s/\[\n\r\|]//g;
	$state =~s/\[\n\r\|]//g;
	$country =~s/\[\n\r\|]//g;
	
	$operatingsystem =~s/\[\n\r\|]//g;
	$favoriteplatform =~s/\[\n\r\|]//g;
	$favoritegame =~s/\[\n\r\|]//g;
	
	$interests =~s/\[\n\r\|]//g;
	$aboutmyself =~s/\[\n\r\|]//g;
	
	$username_ucfirst = ucfirst($username_ucfirst);
	$username_uc = uc($username_ucfirst);
	$username_lc = lc($username_ucfirst);
	$username_lc =~s/ /\-/;
	
	if ($username_ucfirst !~/^[A-Za-z0-9][A-Za-z0-9 ]+[A-Za-z0-9]$/) {
		# INVALID CHARACTERS
		return -11;
	}
	
	$securityphrase = param('securityphrase');
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	return 1;
}

sub UploadAvatar {
	if ($avatar_handle ne '') {
		my $type = uploadInfo($avatar_handle)->{'Content-Type'};
		if (($type eq 'image/jpeg') or ($type eq 'image/pjpeg')) {
			$type = 'jpg';
		}
		elsif (($type eq 'image/gif')) {
			$type = 'gif';
		}
		elsif (($type eq 'image/png')) {
			$type = 'png';
		}
		else {
			#FILE UPLOAD NOT JPEG/PNG/GIF
			return -6;
		}
		
		$avatar_file = "$username_lc.$type";
		my $pathFile = "$config{CONTENT_PATH}/avatars/$avatar_file";
		
		open(HANDLE, ">$pathFile"); 
		while (<$avatar_handle>) { print HANDLE $_; }
		close(HANDLE);

		my $image = new Image::Magick;

		$image->Read($pathFile);
		$image->Scale(width=>60, height=>60);
		$image->Write($pathFile);

		undef $image;
	}
	
	return 1;
}

sub InsertProfile {
	my $pathFile = "$config{ROOT_PATH}/profilemanager.dat";
	my $data = &Enigma::Core::FileRead($pathFile);

	my $insert = "$username_lc|$avatar_file|$realname|$email|$website";
	$insert .= "|$messanger1|$messanger2|$screenname1|$screenname2";
	$insert .= "|$sex|$birth|$city|$state|$country";
	$insert .= "|$operatingsystem|$favoriteplatform|$favoritegame";
	$insert .= "|$interests|$aboutmyself\n";


	
	if ($data =~m/$username_lc\|.*\n/) {
		$data =~s/$username_lc\|.*\n/$insert/;
		$existinguser = 1;
	}
	else { $data .= $insert; }
	Enigma::Core::FileSave($pathFile, $data);

	return 1;
}

sub Update2Fanfare {
	my $pathFile = "$config{WIKI_PATH}/fanfare";
	my $data = &Enigma::Core::FileRead($pathFile);

	my $insert = "<div style='width:25%;float:left;text-align:left;'>\n";
	$insert .= "<a href='profile.pl?id=$username_lc'>";
	$insert .= "$username_ucfirst</a>\n";
	$insert .= "</div>\n";
	$insert .= "<div style='width:25%;float:left;'>-</div>\n";
	$insert .= "<div style='width:25%;float:left;'>-</div>\n";
	$insert .= "<div>-</div>\n";
	$insert .= "<!-- placeholder -->\n";
		
	$data =~s/<!-- placeholder -->\n/$insert/;
	$data =~s/<!-- editorstamp.*>\n//g;
	$data = &Enigma::Core::EditorStamp.$data;
		
	&Enigma::Core::FileSave($pathFile, $data);
	return 1;
}

sub UpdateProfile {
	&GetParameters;
	
	$errorCode = &ParseParameters;
	if ($errorCode ne 1) {
		return $errorCode;
	}

        if ($config{DEFCON} le 2) {
          return -998;
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
	
	$errorCode = &UploadAvatar;
	if ($errorCode ne 1) {
		return $errorCode;
	}
	
	&InsertProfile;
	if ($existinguser eq 0) {
		&Update2Fanfare;
	}
	
	$session{floodinterval} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	return 4;
}

sub GetExistingProfile {
	my $pathFile = "$config{ROOT_PATH}/profilemanager.dat";

	my $data = Enigma::Core::FileRead($pathFile);
	if ($data =~m/$username_lc\|(.*)\n/) {
		($avatar_file, $realname, $email, $website,
		$messanger1, $messanger2, $screenname1, $screenname2,
		$sex, $birth, $city, $state, $country,
		$operatingsystem, $favoriteplatform, $favoritegame,
		$interests, $aboutmyself) = split(/\|/, $1);
		
		return 1;
	}
	
	return 0;
}

sub PrepForCreateDisplay {
	$realname =~s/</&lt;/g;
	$email =~s/</&lt;/g;
	$website =~s/</&lt;/g;
			
	$messanger1 =~s/</&lt;/g;
	$messanger2 =~s/</&lt;/g;
	$screenname1 =~s/</&lt;/g;
	$screenname2 =~s/</&lt;/g;
			
	$sex =~s/</&lt;/g;
	$birth =~s/</&lt;/g;
	$city =~s/</&lt;/g;
	$state =~s/</&lt;/g;
	$country =~s/</&lt;/g;
			
	$operatingsystem =~s/</&lt;/g;
	$favoriteplatform =~s/</&lt;/g;
	$favoritegame =~s/</&lt;/g;
			
	$interests =~s/</&lt;/g;
	$aboutmyself =~s/</&lt;/g;
			
	$realname =~s/>/&gt;/g;
	$email =~s/>/&gt;/g;
	$website =~s/>/&gt;/g;
			
	$messanger1 =~s/>/&gt;/g;
	$messanger2 =~s/>/&gt;/g;
	$screenname1 =~s/>/&gt;/g;
	$screenname2 =~s/>/&gt;/g;
			
	$sex =~s/>/&gt;/g;
	$birth =~s/>/&gt;/g;
	$city =~s/>/&gt;/g;
	$state =~s/>/&gt;/g;
	$country =~s/>/&gt;/g;
			
	$operatingsystem =~s/>/&gt;/g;
	$favoriteplatform =~s/>/&gt;/g;
	$favoritegame =~s/>/&gt;/g;
			
	$interests =~s/>/&gt;/g;
	$aboutmyself =~s/>/&gt;/g;
	
	$realname =~s/['"]/&#39;/g;
	$email =~s/['"]/&#39;/g;
	$website =~s/['"]/&#39;/g;
			
	$messanger1 =~s/['"]/&#39;/g;
	$messanger2 =~s/['"]/&#39;/g;
	$screenname1 =~s/['"]/&#39;/g;
	$screenname2 =~s/['"]/&#39;/g;
			
	$sex =~s/['"]/&#39;/g;
	$birth =~s/['"]/&#39;/g;
	$city =~s/['"]/&#39;/g;
	$state =~s/['"]/&#39;/g;
	$country =~s/['"]/&#39;/g;
			
	$operatingsystem =~s/['"]/&#39;/g;
	$favoriteplatform =~s/['"]/&#39;/g;
	$favoritegame =~s/['"]/&#39;/g;
			
	$interests =~s/['"]/&#39;/g;
	$aboutmyself =~s/['"]/&#39;/g;
	
	return 1;
}

sub InsertCreateDisplay {
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/create-profile");
	
	$document =~s/{avatar_file}/$avatar_file/;
	$document =~s/{avatar_handle}/$avatar_handle/g;
	$document =~s/{username_ucfirst}/$username_ucfirst/g;
	$document =~s/{realname}/$realname/;
	$document =~s/{email}/$email/;
	$document =~s/{website}/$website/;
	
	$document =~s/{birth}/$birth/;
	
	$document =~s/{city}/$city/;
	$document =~s/{state}/$state/;
	$document =~s/{country}/$country/;
	
	$document =~s/{messanger1}/$messanger1/;
	$document =~s/{messanger2}/$messanger2/;
	$document =~s/{screenname1}/$screenname1/;
	$document =~s/{screenname2}/$screenname2/;
	
	$document =~s/{operatingsystem}/$operatingsystem/;
	$document =~s/{favoriteplatform}/$favoriteplatform/;
	$document =~s/{favoritegame}/$favoritegame/;
	
	$document =~s/{securityphrase}/$session{securityphrase}/;
	$document =~s/{interests}/$interests/;
	$document =~s/{aboutmyself}/$aboutmyself/;
	
	if ($messanger1 eq '(AIM)') {
		$document =~s/{messanger1::aim}/checked/; $document =~s/{messanger1::icq}//;
		$document =~s/{messanger1::msn}//; $document =~s/{messanger1::yim}//;
	}
	elsif ($messanger1 eq '(ICQ)') {
		$document =~s/{messanger1::aim}//; $document =~s/{messanger1::icq}/checked/;
		$document =~s/{messanger1::msn}//; $document =~s/{messanger1::yim}//;
	}
	elsif ($messanger1 eq '(MSN)') {
		$document =~s/{messanger1::aim}//; $document =~s/{messanger1::icq}//;
		$document =~s/{messanger1::msn}/checked/; $document =~s/{messanger1::yim}//;
	}
	elsif ($messanger1 eq '(YIM)') {
		$document =~s/{messanger1::aim}//; $document =~s/{messanger1::icq}//;
		$document =~s/{messanger1::msn}//; $document =~s/{messanger1::yim}/checked/;
	}
	else {
		$document =~s/{messanger1::aim}//; $document =~s/{messanger1::icq}//;
		$document =~s/{messanger1::msn}//; $document =~s/{messanger1::yim}//;
	}
	
	if ($messanger2 eq '(AIM)') {
		$document =~s/{messanger2::aim}/checked/; $document =~s/{messanger2::icq}//;
		$document =~s/{messanger2::msn}//; $document =~s/{yim}//;
	}
	elsif ($messanger2 eq '(ICQ)') {
		$document =~s/{messanger2::aim}//; $document =~s/{messanger2::icq}/checked/;
		$document =~s/{messanger2::msn}//; $document =~s/{messanger2::yim}//;
	}
	elsif ($messanger2 eq '(MSN)') {
		$document =~s/{messanger2::aim}//; $document =~s/{messanger2::icq}//;
		$document =~s/{messanger2::msn}/checked/; $document =~s/{messanger2::yim}//;
	}
	elsif ($messanger2 eq '(YIM)') {
		$document =~s/{messanger2::aim}//; $document =~s/{messanger2::icq}//;
		$document =~s/{messanger2::msn}/checked/; $document =~s/{messanger2::yim}/checked/;
	}
	else {
		$document =~s/{messanger2::aim}//; $document =~s/{messanger2::icq}//;
		$document =~s/{messanger2::msn}//; $document =~s/{messanger2::yim}//;
	}
	
	if ($sex eq 'Male') {
		$document =~s/{sex::male}/checked/;
		$document =~s/{sex::female}//;
	}
	elsif  ($sex eq 'Female') {
		$document =~s/{sex::male}//;
		$document =~s/{sex::female}/checked/;
	}
	else {
		$document =~s/{sex::male}//;
		$document =~s/{sex::female}//;
	}
	
	return 1;
}

sub DisplayCreate {
	my $id = param('id');
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	if ($id ne '') {
		$username_ucfirst = ucfirst($id);
		$username_ucfirst =~s/-/ /;
		
		$username_uc = uc($username_ucfirst);
		$username_lc = lc($username_ucfirst);
		$username_lc =~s/ /-/;
		
		$existinguser = &GetExistingProfile;
	}
	
	$session{securityphrase} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	&PrepForCreateDisplay;
	&InsertCreateDisplay;
	
	return 1;
}

sub DisplayFanfare {
	($session{securityphrase}, $session{floodinterval}) = split(/:/, &Enigma::Core::GetSession);
	
	$session{securityphrase} = &Enigma::Core::TimeStamp;
	&Enigma::Core::SetSession("$session{securityphrase}:$session{floodinterval}");
	
	$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/fanfare");
	$document =~s/{id}/Fanfare/;
	$document =~s/{author_ucfirst}//;
	$document =~s/{comment}//;
	$document =~s/{securityphrase}/$session{securityphrase}/;
	
	$document =~s/<!-- errormessage::comment -->//;
	
	return 1;
}

sub DisplayUpdate {
	$errorMsg = &Enigma::Core::GetErrorMessage($errorCode);
		
	if ($errorCode gt 0) {
		&DisplayFanfare;
	}
	else {
		&DisplayCreate;
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
	if ($func eq 'update') {
		$errorCode = &UpdateProfile;
		&DisplayUpdate;
	}
	else {
		&DisplayCreate;
	}
	
	print header;
	&Enigma::Core::TranslateTheme(\$document);
	print $document;
	return 1;
}

sub Display {
	&Initialize;
	
	my $id = param('id');
	$username_ucfirst = ucfirst($id);
	$username_ucfirst =~s/-/ /;
		
	$username_uc = uc($username_ucfirst);
	$username_lc = lc($username_ucfirst);
	$username_lc =~s/ /-/;
	
	&GetExistingProfile;
	
	my $pathFile = "$config{WIKI_PATH}/fanfare-$username_lc";
	if (-e $pathFile) {
		$document = &Enigma::Core::FileRead("$pathFile");
	}
	else {
		$document = &Enigma::Core::FileRead("$config{WIKI_PATH}/fanfare-profile");
	}

	if  ($avatar_file eq '') {
		$avatar_file = 'generic.png';
	}
	
	$document =~s/{avatar_file}/$avatar_file/;
	$document =~s/{username_ucfirst}/$username_ucfirst/g;
	$document =~s/{username_uc}/$username_uc/g;
	$document =~s/{username_lc}/$username_lc/g;
	$document =~s/{realname}/$realname/;
	$document =~s/{email}/$email/;
	$document =~s/{website}/$website/;
	
	$document =~s/{sex}/$sex/;
	$document =~s/{birth}/$birth/;
	$document =~s/{city}/$city/;
	$document =~s/{state}/$state/;
	$document =~s/{country}/$country/;
	
	$document =~s/{messanger1}/<b>$messanger1<\/b> $screenname1/;
	$document =~s/{messanger2}/<b>$messanger2<\/b> $screenname2/;
	
	$document =~s/{operatingsystem}/$operatingsystem/;
	$document =~s/{favoriteplatform}/$favoriteplatform/;
	$document =~s/{favoritegame}/$favoritegame/;
	
	$document =~s/{securityphrase}/$session{securityphrase}/;
	$document =~s/{interests}/$interests/;
	$document =~s/{aboutmyself}/$aboutmyself/;
	
	print header;
	&Enigma::Core::TranslateTheme(\$document);
	print $document;
	return 1;
}

1;
