package Base::Objects::Screen;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );
	use HTML::Template;
	use CGI::Simple;
	use Config::Simple;

	use Base::Objects::Connection;
	use Base::Methods::Session;

	my @template		:Field		:Default( '' )										:Arg(template);
	my @type			:Field		:Default( '' )		:Std(type)						:Arg(type);
	my @args			:Field		:Default( undef );
	my @game			:Field		:Default( undef )	:Get(game)		:Set(set_game);
	my @rate			:Field		:Default( 5000 )	:Std(rate);
	my @stamp_check		:Field		:Default( 1 )		:Std(stamp_check);
	my @temp_fields		:Field;
	my @connection		:Field		:Default( undef )	:Get(connection) :Set(set_connection)	:Arg(connection);
	my @config			:Field		:Default( undef )	:Get(config);
	
	my %init_args :InitArgs = (
        'config' => undef,
    );
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		my $args	= shift;
		
		my $config = undef;
		
		if ( defined( $args->{'config'} ) ) {
			$config = Config::Simple->new( $args->{'config'} );
		}
		else {
			$config = Config::Simple->new( 'config' );
		}
		
		$self->set( \@config, $config );

		unless ( defined( $self->connection() ) ) {
		
			if ( $config->param( 'database' ) ne '' ) {
				$self->set( \@connection, Base::Objects::Connection->new( 'database' => $config->param( 'database' ) ) );			
			}
		}
		
		my $r_args = Base::Methods::Session::parse_input();
		
		$self->set( \@args, $r_args );
		
		if ( $template[ $$self ] eq '' ) {
			my @parts = split( '/', $0 );
			my $text = pop( @parts );
			$text =~ s{ \.pl $ }{\.html}xmsi;	
			$self->set( \@template, $text );
		}
		
		return;
	}

	#############################################

	sub get_arg {
		my $self	= shift;
		my $key		= shift;
		
		if ( defined( $args[ $$self ]->{ $key } ) ) {
			return $args[ $$self ]->{ $key };
		}
		
		return '';
	}
	
	#############################################

	sub gid {
		my $self	= shift;
		
		return $self->get_arg( 'gid', '' );
	}
	
	#############################################

	sub pid {
		my $self	= shift;
		
		return $self->get_arg( 'pid', '' );
	}
	
	#############################################

	sub action {
		my $self	= shift;
		
		return $self->get_arg( 'action', '' );
	}

	#############################################
	
	sub load_game {
		my $self	= shift;
		
		return 0;
	}

	#############################################

	sub header {
		my $self	= shift;
		
		my $cgi = CGI::Simple->new();	

		return $cgi->header();
	}
	
	#############################################
	
	sub body {
		my $self	= shift;
		
		my $template_dir = $self->get_config()->param( 'template_dir' );
	
		my $template = HTML::Template->new( 
			'filename'			=> $template_dir . '/' . $template[ $$self ],
			'die_on_bad_params'	=> 0,
		);
		
		$template->param( %{ $temp_fields[ $$self ] } );
		$template->param( 'gid' => $self->gid() );
		$template->param( 'pid' => $self->pid() );
		$template->param( 'host' => $ENV{'HTTP_HOST'} );
		$template->param( 'script' => $ENV{'SCRIPT_NAME'} );
		$template->param( 'stamp' => $self->get_stamp_value() );
		
		my $output = $template->output;
		
		$output =~ s{ ^ \s* \n }{}xms;
		
		return $output;
	}		
	
	#############################################

	sub process_action {
		my $self	= shift;
		
#		print STDERR "Action: " . $self->action() . ' ... ';
		
		if ( $self->action() eq 'stamp_value' ) {
		
			return $self->respond_ok( $self->get_stamp_value() );
		}
		
		
		return '';
	}

	#############################################

	sub get_stamp_value {
		my $self		= shift;
		
		return $self->connection()->simple_value( 
			'0', 
			"SELECT stamp_value AS value FROM state_change_stamps 
			WHERE game_id=?
			AND stamp_name=?", 
			$self->gid(),
			$type[ $$self ]
		);
	}


	#############################################

	sub show_error {
		my $self	= shift;
		my $message	= shift;
		
		$self->set( \@template, 'error.html' );
		
		$self->set_values( 'error' => $message );
		
		return $self->body();
	}

	#############################################

	sub respond_ok {
		my $self	= shift;
		my $message	= shift;
		
#		my $cgi = CGI::Simple->new();	
#		return $cgi->header() . 'ok:' . $message;
		return 'ok:' . $message;		
	}
	
	#############################################

	sub respond_error {
		my $self	= shift;
		my $message	= shift;
		
#		my $cgi = CGI::Simple->new();	
#		return $cgi->header() . 'error:' . $message;
		return 'error:' . $message;		
	}	
	
	#############################################

	sub set_values {
		my $self	= shift;
		my %values	= @_;
		
		foreach my $key ( keys( %values ) ) {
			$temp_fields[ $$self ]->{ $key } = $values{ $key };
		}
		
		return;		
	}

	#############################################

	sub show_refresh {
		my $self	= shift;
		my $url		= shift;
		
		my $cgi = CGI::Simple->new();	
		print $cgi->header( -Refresh=>'0; URL=http://' . $ENV{'HTTP_HOST'} . $url );

		print '<!DOCTYPE html><html lang="en"><head><title>One Moment</title>';
		print '</head><body style="margin:0px 0px" bgcolor="FFFEEC"></body></html>';
		
		return;	
	}

	#############################################

	sub image_absolute {
		my $self	= shift;
		my $url		= shift;
		my $x		= shift;
		my $y		= shift;
		my $width	= shift;
		my $height	= shift;
		my $shadow	= shift;

		my $style = "position:absolute; top:" . $y . "px; left:" . $x . "px; ";
		
		if ( defined( $width ) ) {
			$style .= 'width: ' . $width . 'px; ';
		}
		
		if ( defined( $height ) ) {
			$style .= 'height: ' . $height . 'px; ';
		}
		
		return "<img src=\"$url\" style=\"$style\">";
	}	

	#############################################

	sub money {
		my $self	= shift;
		my $value	= shift;
		
		my $neg_flag = ( $value < 0 ) ? 1 : 0;
		
		my $text = reverse( $value );
		$text =~ s{ - }{}xms;
		$text =~ s{ (\d\d\d) (?=\d) (?!\d*\.) }{$1,}xmsg;
		$text = '$' . reverse( $text );
		
		if ( $neg_flag ) {
			return '(' . $text . ')';
		}
		
		return $text;
	}

	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
