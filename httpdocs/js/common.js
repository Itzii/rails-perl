var BaseResponse = Object.freeze({
	OK: 	0,
	ERROR:	1,
});

getBaseResponse = function( message ) {

	if ( message.match( /^ok/i ) ) {
		return { type : BaseResponse.OK, text : message.replace( /^ok:\s*/i, '' ) };
	}

	return { type : BaseResponse.ERROR, text : message.replace( /^error:\s*/i, '' ) };
} 
