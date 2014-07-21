package Rails::Screens::Base;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Screen );

	use Base::Objects::Connection;

	use Rails::Objects::Game;

	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		my $args	= shift;

		unless ( defined( $self->connection() ) ) {
			$self->set_connection( Base::Objects::Connection->new( 'database' => 'rails.sqlite' ) );
		}

		return;
	}

	#############################################
	
	sub load_game {
		my $self	= shift;
		
		my $game = Rails::Objects::Game->new( 'connection' => $self->connection() );
		unless ( $game->load_state( $self->gid() ) ) {
			$self->show_error( 'Invalid Game ID' );
			return 0;
		}
		
		$self->set_game( $game );
		
		return 1;
	}

	
	#############################################

	sub process_action {
		my $self	= shift;
		
		my $base_response = $self->Base::Objects::Screen::process_action();
		
		if ( $base_response ne '' ) {
			return $base_response;
		}
		

		
		return '';
	}

	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
