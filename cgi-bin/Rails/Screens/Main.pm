package Rails::Screens::Main;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Screens::Base );

	
	#############################################

	sub _pre_init :PreInit {
		my ( $self, $args ) = @_;
		
		$args->{'type'} = 'main';
		
		return;     
	}

	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		return;
	}

	#############################################

	sub process_action {
		my $self	= shift;
		
		my $common = $self->Rails::Screens::Base::process_action();
		
		if ( $common ne '' ) {
			return $common;
		}
		
		if ( $self->action() eq '' ) {
			return $self->show_main_screen();
		}
		
		elsif ( $self->action() eq 'game_main' ) {

			if ( $self->gid() eq '' ) {
				return $self->show_error( 'Missing Game ID' );
			}
			
			return $self->show_game_screen();
		}
		
		elsif ( $self->action() eq 'create' ) {
		
			return $self->show_create_screen();
		}
		
		elsif ( $self->action() eq 'dump_all_games' ) {
		
			$self->connection()->sql( 'DELETE FROM state_auction' );
			$self->connection()->sql( 'DELETE FROM state_change_stamps' );
			$self->connection()->sql( 'DELETE FROM state_corps' );
			$self->connection()->sql( 'DELETE FROM state_game' );
			$self->connection()->sql( 'DELETE FROM state_players' );
			$self->connection()->sql( 'DELETE FROM state_stations' );
			$self->connection()->sql( 'DELETE FROM state_tile_locations' );
			
		
			return $self->show_main_screen();
		}
		
		return $self->show_error( 'Unknown Action Specified' );
	}
		
	#############################################

	sub show_main_screen {
		my $self	= shift;
		
		$self->set_values( 'show_main' => 1 );
		
		my @games = Rails::Objects::Game::all_games( $self->connection() );
		
		my @lines;

		foreach my $game ( @games ) {
			
			my $completed = '';
			
			if ( $game->{'current_phase'} == 8 ) {
				$completed = ' - Completed';
			}
			
			my %info = (
				'l_gid' => $game->{'id'},
				'l_name'	=> $game->{'game_name'},
				'l_completed'	=> $completed,
			);
			
			push( @lines, \%info );
		}
		
		$self->set_values( 'game_list' => \@lines );
		
		return $self->body();
	}

	#############################################

	sub show_game_screen {
		my $self	= shift;
		my $gid		= shift;
		
		unless ( defined( $gid ) ) {
			$gid = $self->gid();
		}		
		
		my $game = Rails::Objects::Game->new( 'connection' => $self->connection() );
		$game->load_state( $gid );

		$self->set_values( 'show_game' => 1 );
		
		$self->set_values( 's_name' => $game->get_game_name() );


		my @lines = ();

		foreach my $player_index ( 0 .. $game->number_of_players() - 1 ) {
		
			my $player_name = 'Player ' . ( $player_index + 1 );
			
			if ( $game->players()->[ $player_index ]->get_long_name() ne '' ) {
				$player_name = $game->players()->[ $player_index ]->get_long_name();
			}

			my %info = (
				'gid'		=> $gid,
				'l_pid'		=> $player_index,
				'l_name'	=> $player_name,
			);
			
			push( @lines, \%info );
		}
		
		$self->set_values( 'game_list' => \@lines );
		
		return $self->body();
	}

	#############################################

	sub show_create_screen {
		my $self	= shift;
	
		my $count = $self->arg( 'count' );
	
		if ( $count eq '' || $count < 2 || $count > 6 ) {
			return $self->show_error( "Invalid Number Of Players" );
		}
	
		my $gid = Rails::Objects::Game::new_game_id();
	
		my $game = Rails::Objects::Game->new( 'connection' => $self->connection() );	
		$game->new_game( $gid, $count );
		
		return $self->show_game_screen( $gid );
	}	
	
	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
