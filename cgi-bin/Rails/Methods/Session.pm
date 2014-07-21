package Rails::Methods::Session;

use strict;
use warnings;

our @ISA	= qw( Exporter );
our @EXPORT = qw( 
	parse_input
);


#############################################################################

sub parse_input {

	my %buffer = ();

	if ( $#ARGV > 0 ) {
		%buffer = _parse_commandline();
	}
	else {
		%buffer = _parse_cgi();
	}
	
	return \%buffer;
}

#############################################################################

sub _parse_cgi {

    my $buffer_text = '';
	
	if ( exists( $ENV{'REQUEST_METHOD'} ) ) {
	
		my $linebuffer;
	
		if ( $ENV{'REQUEST_METHOD'} eq 'POST' ) {
			read( STDIN, $linebuffer, $ENV{'CONTENT_LENGTH'} );
        
			if ( $linebuffer ne '' ) {
				$linebuffer .= '&';
			}
		}

		if ( exists( $ENV{'QUERY_STRING'} ) ) { 
			$linebuffer .= $ENV{'QUERY_STRING'};
		}

		$buffer_text = $linebuffer;
	}

	my %buffer = ();
	
    foreach ( split( /&/, $buffer_text ) ) {
        my ( $name, $value ) = split( /=/, $_ );

        $name =~ tr/+/ /;
        $name =~ s{ %( [a-fA-F0-9] [a-fA-F0-9] ) }{pack("C", hex($1))}xmsge;

        $value =~ tr/+/ /;
        $value =~ s{ %( [a-fA-F0-9] [a-fA-F0-9] ) }{pack("C", hex($1))}xmsge;
        $value =~ s{ <!--(.|\n)*--> }{}xmsg;
		
		if ( $value ne '' ) {
			$buffer{ $name } = $value;
		}
    }

    return %buffer;                                                              
}

#############################################################################

sub _parse_commandline {

    my @extraargs	= ();
    my %buffer 		= ();

    my $previousname = '';
	
    foreach my $arg ( @ARGV ) {
	
        if ( $arg =~ m{ ^ - }xms ) {
			$arg =~ s{ ^ - }{}xmsg;
			$previousname = $arg;
			$buffer{ $previousname } = 1;
        }
        else {
            if ( $previousname eq '' ) {
                push( @extraargs, $arg );
            }
            else {
                $buffer{ $previousname } = $arg;
                $previousname = '';
            }
        }
    }

    $buffer{ '_args' } = \@extraargs;

    return %buffer;                                                                                                                                                                                                                                                                                                                                                 
}

