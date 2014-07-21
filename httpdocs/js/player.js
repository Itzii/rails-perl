
window.onload = ( function(pre) {
	return function() {
		pre && pre.apply( this, arguments );
		
		window.private_for_sale = document.getElementById('private_for_sale').value;
		window.current_private = window.private_for_sale;
		window.max_bid = parseInt( document.getElementById('maxbid').value );
		window.current_bid = 0;
	
		show_selected( window.private_for_sale );
	}
})(window.onload);

/*
window.onload = function(){

	window.private_for_sale = document.getElementById('private_for_sale').value;
	window.current_private = window.private_for_sale;
	window.max_bid = parseInt( document.getElementById('maxbid').value );
	window.current_bid = 0;
}
*/

function pass() {

	var pass_url = "/cgi-bin/round_private.pl?action=1st_pass_private&gid=" + gid() + "&pid=" + pid();
	
	var response = url_get( pass_url );
	
	if ( response == '' ) {
		location.reload();
	}
}
			
function buy() {

	var buy_url = "/cgi-bin/round_private.pl?action=1st_buy_private&gid=" + gid() + "&pid=" + pid();
	
	console.log( "gid: " + window.value_gid );
	
	console.log( "buy action with url: " + buy_url );
			
	var response = url_get( buy_url );
	
	if ( response == '' ) {
		location.reload();
	}
			
}
			
function bid() {

	var bid_url = "/cgi-bin/round_private.pl?action=1st_bid_private&gid=" + gid() + "&pid=" + pid() + "&bid=" + window.current_bid;
			
	var response = url_get( bid_url );
	
	if ( response == '' ) {
		location.reload();
	}
}

function raise_bid() {

	window.current_bid = window.current_bid + 5;
	check_raise_lower( window.current_private );
}

function lower_bid() {

	window.current_bid = window.current_bid - 5;
	check_raise_lower( window.current_private );
}
			
			
function show_selected( privateID ) { 
			
	var temp = privateID.split( "_" );
	var image_tag = temp[ 1 ];

	var item = document.getElementById( "selected_image" );
	var old_flavor_tag = 'flavor_' + window.current_private;
	var new_flavor_tag = 'flavor_' + privateID;
	
//	console.log( "Old: " + old_flavor_tag );
//	console.log( "New: " + new_flavor_tag );
	
	item.src = "/images/private_" + image_tag + ".png";
	document.getElementById( old_flavor_tag ).style.display="none";
	document.getElementById( new_flavor_tag ).style.display="inline";
	window.current_private = privateID;
//	console.log( "Changed src to " + item.src );
		
	item = document.getElementById( "buy_private" );
	if ( item ) {
		if ( privateID == window.private_for_sale ) {
			item.style.display = "inline";
			
			var buy_item = document.getElementById( "buy_amount" );
			
			if ( buy_item ) {
//				var amount = parseInt( document.getElementById( 'minbid_' + privateID ).value );
				var amount = money( parseInt( document.getElementById( 'minbid_' + privateID ).value ), 0 );

				while ( buy_item.firstChild ) { 
					buy_item.removeChild( buy_item.firstChild ); 
				}
				buy_item.appendChild( document.createTextNode( amount ) );
			}
		}
		else {
			item.style.display = "none";
		}
	}				
	
	item = document.getElementById( "bid_private" );
	if ( item ) {

		if ( privateID == window.private_for_sale ) {
			item.style.display = "none";
		}
		else {
	
			window.current_bid = parseInt( document.getElementById( 'minbid_' + privateID ).value ) + 5;
			
			if ( window.current_bid > window.max_bid ) {
				item.style.display="none";
			}
			else {
				item.style.display = "inline";
				check_raise_lower( privateID );		
			}
		}

	}
	
}

function check_raise_lower ( privateID ) {

	var raise_bid = document.getElementById( "raise_bid" );
	var lower_bid = document.getElementById( "lower_bid" );
		
	var min_bid = parseInt( document.getElementById( 'minbid_' + privateID ).value );
	
	if ( raise_bid ) {
		if ( window.current_bid >= window.max_bid ) {
			raise_bid.style.display="none";
		}
		else {
			raise_bid.style.display="inline";
		}
	}
	
	if ( lower_bid ) {
		if ( window.current_bid <= min_bid + 5 ) {
			lower_bid.style.display="none";
		}
		else {
			lower_bid.style.display="inline";
		}
	}
	
	var bid_item = document.getElementById( "bid_amount" );
				
	if ( bid_item ) {
		var amount = money( window.current_bid, 0 );
		
		while ( bid_item.firstChild ) { 
			bid_item.removeChild( bid_item.firstChild ); 
		}
		bid_item.appendChild( document.createTextNode( amount ) );
	}
	
}
