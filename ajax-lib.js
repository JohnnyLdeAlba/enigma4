function get_ajax_interface()
{
	if (window.XMLHttpRequest)
		return new XMLHttpRequest();
	if (window.ActiveXObject)
		return new ActiveXObject("Microsoft.XMLHTTP");
	
	return null;
}

var ajax_interface = get_ajax_interface();

function request_get(action, _handler_function)
{
	if (ajax_interface == null) {
		if (action.match(/^module/) == "module")
			action = action.replace(/module\/(.+).htm/, "display.php?module=$1");

		window.location = action;
		return;
	}

	if (action.match(/^enigma.php/) == "enigma.php")
		action = action + "&method=get";

	if (ajax_interface.readyState == 0 || ajax_interface.readyState == 4)
	{
		ajax_interface.open("GET", action, true);

		ajax_interface.onreadystatechange = _handler_function;
		ajax_interface.send(null);
	}
}

function get_responce() {
	return ajax_interface.responseText;
}

function get_element_interface(id) {
	return document.getElementById(id);
}

function toggle_display(id) {
	element = get_element_interface(id);
	
	if (element.style.display == 'inline')
		element.style.display = 'none';
	else
		element.style.display = 'inline';
}

function _handler_hyperlink() {
	if (ajax_interface.readyState == 4) {
		var viewport = new get_element_interface('viewport');
		viewport.innerHTML = get_responce();
		toggle_display('load_indicator');
	}
}

function hyperlink(action) {
	toggle_display('handle_indicator');
	request_get(action, _handler_hyperlink);
}

function popuplink(action) {
	var wndhandle = window.open(action,'_blank','width=640,height=480,menubar=0,directories=0,toolbar=0,status=0,scrollbars=1,resizable=0');
}

function set_cookie(id, value) {
	var date = new Date();
	date.setTime(date.getTime()+86400000*30);

	document.cookie = id+"="+escape(value)+";expires="+date.toGMTString()+";";
}

function retrieve_cookie(id) {
	if (document.cookie.length > 0) {
		start_index = document.cookie.indexOf(id + '=');
  
		if (start_index == -1) return null;
		start_index = start_index + (id.length+1);
		
		end_index = document.cookie.indexOf(";", start_index);
		if (end_index == -1) end_index = document.cookie.length;
		
		return unescape(document.cookie.substring(start_index, end_index))
	}
	return null;
}

function retrieve_get(id) {
	var url = new String(document.location);
	start_index = url.indexOf(id + '=');
  
	if (start_index == -1) return null;
	start_index = start_index + (id.length+1);
		
	end_index = url.indexOf("&", start_index);
	if (end_index == -1) end_index = url.length;
		
	return unescape(url.substring(start_index, end_index))
}

function jukebox(file) {
	var jukebox = new get_element_interface('jukebox');	

	if (file == null) {
		jukebox.innerHTML = '';
		return;
	}

	var data = "<object type='application/x-shockwave-flash'";
	data += " width='17' height='17' data='../eccoserv/flash/musicplayer.swf?";
	data += "&autoplay=true&repeat=true";
	data += "&song_url="+file+"'>";
	
	data += "<param name='movie' value='../eccoserv/flash/musicplayer.swf?";
	data += "&autoplay=true&repeat=true";
	data += "&song_url="+file+"' />";
	
	data += "</object>";

	jukebox.innerHTML = data;
}