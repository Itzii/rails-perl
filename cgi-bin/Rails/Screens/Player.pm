package Rails::Screens::Player;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Screens::Base );
	use Rails::Methods::Privates;

	#############################################

	sub _pre_init :PreInit {
		my ( $self, $args ) = @_;
		
		$args->{'type'} = 'player';
		
		return;     
	}

	#############################################
	
	sub _init	:Init {
		my $self	= shift;
			
		return;
	}

	#############################################

	sub player {
		my $self	= shift;
		
		return $self->game()->players()->[ $self->pid() ];
	}

	#############################################

	sub base_url {
		my $self	= shift;
		
		return "/cgi-bin/screen_player.pl?gid=" . $self->gid() . "&pid=" . $self->pid();
	}

	#############################################

	sub process_action {
		my $self	= shift;
				
		$self->set_type( 'player_' . $self->pid() );
		$self->load_game();
		
		$self->set_values( 's_name' => $self->player()->display_name() );

		my $common = $self->Rails::Screens::Base::process_action();
		
		if ( $common ne '' ) {
			return $common;
		}
		
	
		if ( $self->action() eq '' ) {
			$self->game()->log_event( 'Empty Player Action' );
			return $self->show_main_screen();
		}
		elsif ( $self->action() eq 'set_name' ) {
			return $self->do_change_name();
		}		
		
		
		return $self->show_error( 'Unknown Action Specified' );
	}

	#############################################

	sub show_main_screen {
		my $self		= shift;
		
		if ( $self->player()->get_long_name() eq '' ) {
			$self->set_stamp_check( 0 );
			return $self->show_screen_select_name();		
		}
		elsif ( $self->game()->get_current_phase() < 0 ) {
			return $self->show_screen_privates();
		}
		elsif ( $self->game()->get_current_round() == 0 ) {
			return $self->show_screen_stock();
		}
		else {
			return $self->show_screen_operating();
		}
	}	

	#############################################

	sub do_change_name {
		my $self		= shift;
		
		if ( $self->arg( 'new_name' ) eq '' ) {
			return $self->show_error( 'No Name Selected' );
		}
		
		$self->player()->set_long_name( $self->arg('new_name') );
		$self->player()->save_state();
		
		$self->game()->log_event( "Player " . $self->pid() . " has set name to '" . $self->player()->get_long_name() . "'" );
		
		return $self->show_main_screen();
	}		

	#############################################

	sub show_screen_select_name {
		my $self		= shift;
		
		$self->set_values( 'show_change_name' => 1 );
		
		return $self->body();
	}
	
	#############################################

	sub show_screen_privates {
		my $self		= shift;
		
		$self->set_values( 'show_privates' => 1 );
		
		my @lines = ();
		
		my @privates = $self->game()->all_private_keys();
		my $private_for_sale = $privates[ 0 ];
		
		$self->set_values( 'private_for_sale' => $private_for_sale );
		$self->set_values( 'is_current_player' => ( $self->game()->get_current_player_id() == $self->pid() ) ? 1 : 0 );


		my @min_bid_lines = ();

		foreach my $private ( @privates ) {
			my $high_bid = Rails::Methods::Privates::get_highest_bid( $self->game(), $private );
			
			if ( $high_bid == -1 ) {
				$high_bid = $self->game()->private_cost( $private );
			}
			
			push( @min_bid_lines, { 'private_key' => $private, 'private_min_bid' => $high_bid } );
		}
		
		$self->set_values( 'min_bids' => \@min_bid_lines );
		$self->set_values( 'max_bid' => $self->player()->get_cash() );
		$self->set_values( 'player_money' => $self->player()->get_cash() );
		


		my @player_ids = $self->game()->all_player_ids();
		
		while ( $player_ids[ 0 ] != $self->pid() ) {
			push( @player_ids, shift( @player_ids ) );
		}
		
		my @other_lines = ();
		foreach my $pid ( @player_ids ) {
		
			push( 
				@other_lines, 
				{ 
					'other_name' => $self->game()->players()->[ $pid ]->display_name(), 
					'other_cash' => $self->game()->players()->[ $pid ]->get_cash(),
					'other_current'	=> ( $pid == $self->game()->get_current_player_id() ) ? 1 : 0,					
				} 
			);
		}
		$self->set_values( 'players' => \@other_lines );
		
		
		my @private_lines = ();
		
		foreach my $private ( reverse @privates ) {
		
			my ( $junk, $private_tag ) = split( /_/, $private );

			my %auction_players = map { $_ => 1 } Rails::Methods::Privates::get_ordered_auction_players( $self->game(), $private );
			
			my @private_inner_lines = ();
			
			foreach my $pid ( @player_ids ) {
			
				my %inner_info = (
					'private_available'	=> ( $self->game()->holds_private( $private ) ) ? 1 : 0,
					'private_owned'		=> ( $self->game()->players()->[ $pid ]->holds_private( $private ) ) ? 1 : 0,
					'private'			=> $private,
					'private_tag'		=> $private_tag,
				);
				
				push( @private_inner_lines, \%inner_info );
			}		
			
			my %info = (
				'private_available'	=> ( $self->game()->holds_private( $private ) ) ? 1 : 0,
				'private'			=> $private,
				'private_tag'		=> $private_tag,
				'privates_inner'	=> \@private_inner_lines,
			);

			push( @private_lines, \%info );
		}
		
		$self->set_values( 'privates' => \@private_lines );
		
		
		
		
		my ( $junk, $private_tag ) = split( /_/, $private_for_sale );
		
		$self->set_values( 'private_tag' => $private_tag );
		
		my @flavor_lines = ();
		
		foreach my $private ( reverse @privates ) {
			my ( $junk, $private_tag ) = split( /_/, $private );
			
			my %info = (
				'for_sale'		=> ( $private eq $private_for_sale ) ? 1 : 0,
				'private'		=> $private,
				'flavor_text'	=> $self->game()->private_flavor( $private ),
			);
			
			push( @flavor_lines, \%info );
		}
		
		$self->set_values( 'flavor' => \@flavor_lines );

		return $self->body();
	}

	#############################################

	sub show_screen_stock {
		my $self		= shift;
		
		$self->set_values( 'show_stock' => 1 );
		
		return $self->body();
	}

	#############################################

	sub show_screen_operating {
		my $self		= shift;
		
		$self->set_values( 'show_operating' => 1 );
		
		return $self->body();
	}

	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
