package Rails::Methods::Privates;

use strict;
use warnings;

our @ISA	= qw( Exporter );
our @EXPORT = qw( 
	get_waiting_on
	players_in_auction
	get_bid_amount
	get_highest_bidder
	get_highest_bid
	get_current_bidder
	get_ordered_auction_players
	par_positions;
);

#############################################################################

sub get_waiting_on {
	my $game		= shift;
	
	if ( $game->get_current_phase() == -3 ) {
		
		foreach my $pid ( $game->all_player_ids() ) {
			if ( $game->players()->[ $pid ]->holds_private( '5_bo' ) == 1 ) {
				return $pid;
			}
		}
	}
	
	return $game->connection()->simple_value(
		-1,
		"SELECT player_id FROM state_auction WHERE
		game_id=? AND waiting_on=1",
		$game->get_id(),
	);
}
	
#############################################################################

sub players_in_auction {
	my $game		= shift;
	my $private		= shift;
	
	return $game->connection()->simple_hash(
		"SELECT player_id AS keyfield, bid AS value FROM state_auction 
		WHERE game_id=? AND private_id=?",
		$game->get_id(), $private,
	);
}

#############################################################################

sub get_bid_amount {
	my $game		= shift;
	my $private		= shift;
	my $player_id	= shift;
	
	return $game->connection()->simple_value(
		0,
		"SELECT bid AS value FROM state_auction
		WHERE game_id=? AND private_id=? AND player_id=?",
		$game->get_id(), $private, $player_id,
	);
}

#############################################################################

sub get_highest_bidder {
	my $game		= shift;
	my $private		= shift;
	
	return $game->connection()->simple_value(
		-1,
		"SELECT player_id AS value FROM state_auction WHERE game_id=? AND private_id=?
		ORDER BY bid DESC LIMIT 1",
		$game->get_id(), $private,
	);
}

#############################################################################

sub get_highest_bid {
	my $game		= shift;
	my $private		= shift;
	
	return $game->connection()->simple_value(
		-1,
		"SELECT bid AS value FROM state_auction WHERE game_id=? AND private_id=?
		ORDER BY bid DESC LIMIT 1",
		$game->get_id(), $private,
	);
}

#############################################################################

sub get_current_bidder {
	my $game		= shift;
	my $private		= shift;
	
	my @ids = get_auction_players( $game, $private );
	
	return $ids[ 0 ];
}

#############################################################################

sub get_ordered_auction_players {
	my $game		= shift;
	my $private		= shift;
	
	# Get the ids of the auction participants and sort them by player order

	my %participants = players_in_auction( $game, $private );

	my %new_id_hash = ();
	foreach ( keys( %participants ) ) {
		$new_id_hash{ $_ } = 1;
	}
	
	my @player_ids = $game->all_player_ids();
	my @new_ids = ();
	
	foreach ( @player_ids ) {
		if ( exists( $new_id_hash{ $_ } ) ) {
			push( @new_ids, $_ );
		}
	}
	
	if ( @new_ids ) {
		# loop through the list to find the player AFTER the current high bidder
	
		my $high_id = get_highest_bidder( $game, $private );
	
		my $shift_flag = 1;
		while ( $shift_flag == 1 ) { 
			my $id = shift( @new_ids );
			push( @new_ids, $id );
			if ( $id == $high_id ) {
				$shift_flag = 0;
			}
		}
	}
	
	return @new_ids;
}

#############################################################################

sub par_positions {
	my $par_value		= shift;
	
	my %values = (
		'100'	=> '6,0',
		'90'	=> '6,1',
		'82'	=> '6,2',
		'76'	=> '6,3',
		'67'	=> '6,4',
	);
	
	if ( exists( $values{ $par_value } ) ) {
		return $values{ $par_value };
	}
	
	return '';
}

#############################################################################
#############################################################################
1