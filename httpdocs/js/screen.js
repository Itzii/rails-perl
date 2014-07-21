

setInterval( function(){checkStamp()}, 5000 );

window.onload = ( function(pre) {
	return function() {
		pre && pre.apply( this, arguments );
		
		window.check_flag = 1;

		window.value_current_stamp = document.getElementById('stamp').value;
		window.value_host = document.getElementById('host').value;
		window.value_script = document.getElementById('script').value;
		window.value_gid = document.getElementById('gid').value;
		window.value_pid = '';

		var item = document.getElementById('pid');
		if ( item ) {
			value_pid = item.value;
		}
		
		console.log( "GID original value: " + window.value_gid );
		
	}
})(window.onload);

function host() {
	return window.value_host;
}

function script() {
	return window.value_script;
}

function gid() {
	return window.value_gid;
}

function pid() {
	return window.value_pid;
}

function checkStamp() {
	if ( window.check_flag == 1 ) {


		var check_url = "http://" + window.value_host + window.value_script + "?action=stamp_value&gid=" + window.value_gid;
		
		if ( window.value_pid != '' ) {
			check_url = check_url + "&pid=" + window.value_pid;
		}
		
		var response = url_get( check_url );
		
		console.log( "Current Stamp: " + response );
	
		if ( response != window.value_current_stamp ) {
			location.reload();
		}	
	}
};

function url_get( url ) {

	var xmlHttp = new XMLHttpRequest();
	
	xmlHttp.open( "GET", url, false );
	xmlHttp.send();

	console.log( "Response: " + xmlHttp.responseText );
	
	var response = getBaseResponse( xmlHttp.responseText );
	
	if ( response.type == "error" ) {
		alert( "Server Returned Error: " + response.text );
		console.log( response.text );
	}

	return response.text;
}

function money ( n, c, d, t ){

	c = isNaN(c = Math.abs(c)) ? 2 : c;
	d = d == undefined ? "." : d; 
	t = t == undefined ? "," : t;
	
	var s = n < 0 ? "-" : "";
	var i = parseInt( n = Math.abs( +n || 0 ).toFixed( c ) ) + "";
	var j = ( j = i.length ) > 3 ? j % 3 : 0;
		
	return s + "$" + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};


