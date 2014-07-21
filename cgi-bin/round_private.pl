#!/usr/bin/perl


use strict;
use warnings;

use CGI::Simple;

use Rails::Methods::Session;
use Rails::Methods::Privates;
use Rails::Objects::Game;
use Rails::Objects::Connection;

$| = 1;

my $doc = <<'ACTIONS';
-----
1st_buy_private

	gid		: (number)
	pid		: (number)
	par		: (number) - optional, only required for 5_bo
	
-----
1st_bid_private

	gid		: (number)
	pid		: (number)
	private	: (text)
	bid		: (number)
	
-----
1st_pass_private

	gid		: (number)
	pid		: (number)
	
-----
auction_raise_bid

	gid		: (number)
	pid		: (number)
	bid		: (number)

-----
auction_concede

	gid		: (number)
	pid		: (number)

-----
set_bo_par

	gid		: (number)
	pid		: (number)
	par		: (number)

-----
ACTIONS


my $cgi = CGI::Simple->new();	
print $cgi->header();
print main();

#############################################################################

sub main {

	my $r_args = Rails::Methods::Session::parse_input();
	
	unless ( keys( %{ $r_args } ) ) {
		return 'error:Missing Arguments';
	}

	my $connection = Rails::Objects::Connection->new( 'database' => 'rails.sqlite' );

	my $game = Rails::Objects::Game->new( 'connection' => $connection );
	
	my $action 	= $r_args->{'action'};
	my $gid		= $r_args->{'gid'};
	
	if ( $action eq '' ) {
		return 'error:Missing Action';
	}
		
	if ( $game->load_state( $gid ) == 0 ) {
		return 'error:Invalid Game ID';
	}
	
	
	if ( $action eq '1st_pass_private' ) {
		return _1st_pass_private( $game, $r_args );
	}
	elsif ( $action eq '1st_buy_private' ) {
		return _1st_buy_private( $game, $r_args );
	}	
	elsif ( $action eq '1st_bid_private' ) {
		return _1st_bid_private( $game, $r_args );
	}

	elsif ( $action eq 'auction_raise_bid' ) {
		return _auction_raise_bid( $game, $r_args );
	}
	elsif ( $action eq 'auction_concede' ) {
		return _auction_concede( $game, $r_args );
	}

	elsif ( $action eq 'set_bo_par' ) {
		return _set_bo_par( $game, $r_args );
	}
	
	else {
		return 'error:Unknown Action';
	}
	
	return;
}

#############################################################################
#############################################################################

sub _1st_pass_private {
	my $game		= shift;
	my $r_args		= shift;
	
	if ( $game->get_current_phase() != -1 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != $game->get_current_player() ) {
		return 'error:Invalid PID';
	}
	
	$game->set_player_pass( $pid );
	
	if ( $game->have_all_passed() == 0 ) {
		$game->next_player();
		$game->save_state();
		$game->tick_auction_stamp();
		$game->tick_all_players_stamp();
		
		return 'ok';
	}
	
	$game->clear_pass_flags();
	
	$game->log_event( $game, "All Players have passed." );
	
	my $private = $game->first_private();
	
	if ( $private eq '0_sv' ) {
		$game->set_depreciation( $game->get_depreciation() + 1 );
		my $text = sprint( "Cost of %s reduced to %s", $game->private_name( $private ), $game->private_cost( $private ) );
		$game->log_event( $game, $text );	
		
		$game->next_player();	
		
		if ( $game->private_cost( $private ) == 0 ) {
		
			$pid = $game->current_player();
		
			$game->remove_private( $private );
			$game->players()->[ $pid ]->add_private( $private );
	
			$game->log_event( $game, "Player $pid received $private for free" );
	
			$game->next_priority_player( $pid );
			
			_auto_auction( $game );
			
		}
		
		$game->save_state();
		$game->tick_auction_stamp();
		$game->tick_all_players_stamp();
		
		return 'ok';
	}
	
	$game->pay_privates();	
	$game->next_player();
	
	$game->save_state();
	$game->tick_auction_stamp();
	$game->tick_all_players_stamp();
	
	return 'ok';	
}

#############################################################################

sub _1st_buy_private {
	my $game		= shift;
	my $r_args		= shift;
	
	if ( $game->get_current_phase() -1 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != $game->get_current_player() ) {
		return 'error:Invalid PID';
	}
	
	my $private = $game->first_private();
	
	my $cost = $game->private_cost( $private );
	
	if ( $cost > $game->players()->[ $pid ]->get_cash() ) {
		return 'error:Not Enough Cash';
	}
	
	# All ok. Buy Private Company
	
	my $player = $game->players()->[ $pid ];
	
	$player->adjust_cash( - $cost );
	
	$player->add_private( $private );
	$game->remove_private( $private );
	
	$game->log_event( "Player $pid purchased $private for $cost" );
	
	$game->clear_player_pass( $pid );
	$game->next_priority_player( $pid );
	
	my $t_phase = _check_for_special_buys( $game, $player, $private, $r_args->{'par'} );
	if ( $t_phase != $game->get_current_phase() ) {
		$game->set_next_phase( $game->get_current_phase() );
		$game->set_current_phase( $t_phase );

		return 'ok';
	}
	
	
	return _check_for_end_of_auctions( $game );
}

#############################################################################

sub _1st_bid_private {
	my $game		= shift;
	my $r_args		= shift;
	
	if ( $game->get_current_phase() != -1 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != $game->get_current_player() ) {
		return 'error:Invalid PID';
	}
	
	my $private = $r_args->{'private'};
	
	if ( $game->has_private( $private ) == 0 ) {
		return 'error:Invalid Private';
	}
	
	if ( $private eq $game->first_private() ) {
		return 'error:May Not Bid On First Private';
	}
	
	my $bid = $r_args->{'bid'};
	
	if ( $bid < $game->minimum_bid_for_auction( $private ) ) {
		return 'error:Bid Too Low';
	}
	
	$game->make_auction_bid( $private, $pid, $bid );
	$game->players()->[ $pid ]->adjust_cash( - $bid );
	
	$game->log_event( "Player $pid set bid on $private of $bid" );
	
	$game->clear_player_pass( $pid );
	
	$game->next_player();
	
	$game->save_state();
	
	return 'ok';	
}

#############################################################################

sub _auction_raise_bid {
	my $game		= shift;
	my $r_args		= shift;
	
	if ( $game->get_current_phase() != 0 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $private = $game->first_private();
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != get_waiting_on( $game ) ) {
		return 'error:Invalid PID';
	}
	
	my $bid = $r_args->{'bid'};
	my $high = get_highest_bid( $game, $private );
	
	if ( $bid < $high + 5 ) {
		return 'error:Bid Too Low';
	}

	my %current_bids = Rails::Methods::Privates::players_in_auction( $game, $private );

	my $difference = $bid - $current_bids{ $pid };
	
	if ( $game->players()->[ $pid ]->get_cash() < $difference ) {
		return 'error:Not Enough Cash';
	}	
	
	$game->players()->[ $pid ]->adjust_cash( - $difference );
	_make_auction_bid( $game, $private, $pid, $bid );
	
	$game->log_event( "Player $pid raises to $bid" );
	
	my @player_ids = Rails::Methods::Privates::get_ordered_auction_players( $game, $private );
	
	_wait_on( $player_ids[ 0 ] );

	$game->save_state();
	$game->tick_auction_stamp();
	$game->tick_all_players_stamp();
	
	return 'ok';
}

#############################################################################

sub _auction_concede {
	my $game		= shift;
	my $r_args		= shift;
	
	if ( $game->get_current_phase() != 0 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $private = $r_args->{'private'};
	
	if ( $private ne $game->first_private() ) {
		return 'error:Invalid Private';
	}
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != get_waiting_on( $game ) ) {
		return 'error:Invalid PID';
	}
	
	my %current_bids = Rails::Methods::Privates::players_in_auction( $game, $private );

	$game->players()->[ $pid ]->adjust_cash( $current_bids{ $pid } );

	_remove_bid( $game, $private, $pid );
	$game->log_event( "Player $pid withdraws bid" );
	
	delete( $current_bids{ $pid } );
	
	# Are there more bids on this private?
	
	if ( scalar( keys( %current_bids ) ) > 1 ) {
	
		# Yes
		
		my @player_ids = get_ordered_auction_players( $game, $private );
		_wait_on( $player_ids[ 0 ] );
		
		while ( shift( @{ $game->auction_players() } ) ) { }
		push( @{ $game->auction_players() }, @player_ids );
		
		$game->save_state();
		$game->tick_auction_stamp();
		$game->tick_all_players_stamp();
	
		return 'ok';
	}
	
	# No
	
	$pid = (keys( %current_bids ))[ 0 ];
		
	$game->remove_private( $private );
	$game->players()->[ $pid ]->add_private( $private );
	_remove_bid( $game, $private, $pid );

	$game->log_event( "Player $pid purchased $private for " . $current_bids{ $pid } );
	while ( shift( @{ $game->auction_players() } ) ) { }
	
	return _check_for_end_of_auctions( $game );
}

#############################################################################

sub _set_bo_par {
	my $game	= shift;
	my $r_args	= shift;

	if ( $game->get_current_phase() != -3 ) {
		return 'error:Incorrect Game Phase';
	}
	
	my $pid = $r_args->{'pid'};
	
	if ( $pid != get_waiting_on( $game ) ) {
		return 'error:Invalid PID';
	}
	
	my $par = $r_args->{ 'par' };
	
	my $position = Rails::Methods::Privates::par_positions( $par );
	
	if ( $position eq '' ) {
		return 'error:Invalid Par Value';
	}
	
	$game->corps()->set_par_price( $par );
	$game->corps()->set_current_position( Rails::Methods::Privates::par_positions( $par ) );
	$game->log_event( "Par price for bo set to $par" );
	
	$game->set_current_phase( $game->get_next_phase() );
	$game->set_next_phase( -1 );
	
	return _check_for_end_of_auctions( $game );

}	
	
#############################################################################

sub _auto_auction {
	my $game		= shift;
	
	# Are there bids on the next company
	
	my $private = $game->first_private();
	
	my %participants = players_in_auction( $game, $private );
	
	if ( scalar( keys( %participants ) ) == 0 ) {
		return;
	}
	
	if ( scalar( keys( %participants ) ) == 1 ) {
		my $pid = (keys( %participants ))[ 0 ];
	
		$game->remove_private( $private );
		$game->players()->[ $pid ]->add_private( $private );
		
		my $bid = get_bid_amount( $game, $private, $pid );
		$game->adjust_cash( $bid );
		
		$game->log_event( "Player $pid purchased $private in uncontested auction for $bid" );
		
		return;
	}
	
	my @players = get_ordered_auction_players( $game, $private );
	
	while ( shift( @{ $game->auction_players() } ) ) { }
	push( @{ $game->auction_players() }, @players );
	
	$game->log_event( "Auction has begun on $private with bidders: " . join( ',' . @players ) );
	
	my $high = get_highest_bid( $game, $private );
	my $highest_bidder = get_highest_bidder( $game, $private );
	
	$game->log_event( "Current high bid is $high from $highest_bidder." );
	_wait_on( $game, $private, $players[ 0 ] );	
	
	$game->set_current_phase( 0 );
	
	return;	
}
	
#############################################################################

sub check_for_end_of_auctions {
	my $game		= shift;

	# Are there more privates to auction?
	
	if ( $game->first_private() ne '' ) {
	
		# Yes
	
		$game->set_current_phase( -1 );
	
		_auto_auction( $game );

		$game->save_state();
		$game->tick_auction_stamp();
		$game->tick_all_players_stamp();
	
		$game->log_event( "Waiting for Player " . $game->get_current_player() );
		return 'ok';
	}
	
	# No
	
	$game->set_current_phase( 2 );
	$game->set_next_phase( 2 );
	$game->log_event( "Phase 2 Begins" );
	
	$game->set_current_round( 0 );
	$game->log_event( "Stock Round Begins -----" );
	
	$game->set_current_player( $game->get_priority_player() );
	$game->log_event( "Waiting for Player " . $game->get_current_player() );
	
	$game->save_state();
	$game->tick_auction_stamp();
	$game->tick_all_players_stamp();
	
	return 'ok';	

}
	
#############################################################################

sub _make_auction_bid {
	my $game		= shift;
	my $private		= shift;
	my $player_id	= shift;
	my $bid			= shift;

	$game->connection()->sql( 
		"DELETE FROM state_auction WHERE game_id=? AND private_id=? AND player_id=?",
		$game->get_id(), $private, $player_id,
	);
	
	$game->connection()->sql(
		"INSERT INTO state_auction ( game_id, private_id, player_id, bid, waiting_on )
		VALUES ( ?, ?, ?, ?, 0 )",
		$game->get_id(), $private, $player_id, $bid,
	);
	
	return;
}
	
#############################################################################

sub _check_for_special_buys {
	my $game		= shift;
	my $player		= shift;
	my $private		= shift;
	my $par			= shift;
	
	
	if ( $private eq '4_ca' ) {
	
		$player->add_shares( 'prr', 1 );
		$game->corps()->{ 'prr' }->remove_shares( 'prr', 1 );
		$game->log_event( 'Player $pid receives free share of prr from the bank' );
		
	}
	elsif ( $private eq '5_bo' ) {
		$player->add_shares( 'bo', 2 );
		$game->corps()->{ 'bo' }->remove_shares( 'bo', 2 );
	
		if ( $par eq '' ) {
			$game->log_event( 'Player $pid receives 2 free shares of bo from the bank' );
			$game->log_event( 'Waiting for par value for bo' );
			
			return -3;
		}
		else {
			$game->corps()->{ 'bo' }->set_par_price( $par );
			$game->log_event( "Player " . $player->get_id() . " receives free share of prr from the bank setting the par value to $par" );
		}
	}
	
	
	return $game->get_current_phase();
}
	
#############################################################################

sub _remove_bid {
	my $game		= shift;
	my $private		= shift;
	my $player_id	= shift;
	
	$game->connection()->sql(
		"DELETE FROM state_auction 
		WHERE game_id=? AND private_id=? AND player_id=?",
		$game->get_id(), $private, $player_id,
	);
	
	return;
}

#############################################################################
	
sub _wait_on {
	my $game		= shift;
	my $private		= shift;
	my $player_id	= shift;
	
	$game->connection()->sql(
		"UPDATE state_auction SET waiting_on=0 WHERE game_id=? AND private_id=?",
		$game->get_id(), $private,
	);
	
	$game->connection()->sql(
		"UPDATE state_auction SET waiting_on=1
		WHERE game_id=? AND private_id=? AND player_id=?",
		$game->get_id(), $private, $player_id,
	);
	
	$game->log_event( "Current bidder is " . $player_id );

	return;
}
	
#############################################################################
#############################################################################
1