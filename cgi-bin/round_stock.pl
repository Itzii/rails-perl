#!/usr/bin/perl


use strict;
use warnings;

use CGI::Simple;

use Rails::Objects::Game;
use Rails::Objects::Connection;

$| = 1;

my $doc = <<'ACTIONS';
-----
exchange_mh

	pid		: (number)
	location: (text) bank|market
	
-----
buy_new

	pid		: (number)
	corp	: (text)
	
	
-----
buy_market

	pid		: (number)
	corp	: (text)
	count	: (number)

-----
sell

	pid		: (number)
	corp	: (text)
	count	: (number)

-----
done

	pid		: (number)

-----
ACTIONS





print main();


sub main {

	my $r_args = PSG::Methods::Session::parse_input();
	
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
	
	if ( $game->get_current_phase() < 2 && $game->get_current_phase() > 7 ) {
		return 'error:Incorrect Game Phase';
	}

	if ( $action eq 'exchange_mh' ) {
		return _exchange_mh( $game, $r_args );
	}

	my $pid = $r_args->{'pid'};

	if ( $pid != $game->get_current_player_id() ) {
		return 'error:Invalid PID';
	}



	if ( $action eq 'buy_new' ) {
		return _buy_new( $game, $r_args );
	}
	elsif ( $action eq 'buy_market' ) {
		return _buy_market( $game, $r_args );
	}
	elsif ( $action eq 'sell' ) {
		return _sell( $game, $r_args );
	}
	elsif ( $action eq 'done' ) {
		return _done( $game, $r_args );
	}
	
	else {
		return 'error:Unknown Action';
	}
	
	return;
}

#############################################################################
#############################################################################

sub _buy_new {
	my $game		= shift;
	my $r_args		= shift;
	
	my $pid = $r_args->{'pid'};
	my $player = $game->players()->[ $pid ];

	my $corp_key = $r_args->{'corp'};
	my $corp = $game->corps()->{ $corp_key };
	
	my $count = 1;
	
	if ( $corp->share_count() < 1 ) {
		return 'error:No Shares Available';
	}
	
	if ( $game->ceo_of_corp( $corp_key ) == -1 ) {
		$count = 2;
	}	
	
	if ( $player->total_certificate_count() + 1 > $game->maximum_certificates() ) {
		return 'error:Too Many Certificates';
	}

	if ( $player->did_sell_this_round( $corp_key ) == 1 ) {
		return 'error:Sold This Round';
	}
	
	my $par = $r_args->{'par'};
	my $value = $game->corps()->{ $corp_key }->get_par_price();
	
	if ( $count == 2 && $corp_key ne 'prr' ) {
		my $new_position = par_positions( $par );
		
		if ( $new_position eq '' ) {
			return 'error:Invalid Par Value';
		}
		
		$value = $par;
	}


	if ( $player->get_cash() < $value * $count ) {
		return 'error:Not Enough Cash';
	}
	
	my $total = $value * $count;

	$player->add_shares( $corp_key, $count );
	$corp->remove_shares( $corp_key, $count );
	
	$player->add_to_bought_this_round( $corp_key );

	$player->adjust_cash( - $total );
	$game->adjust_cash( $total );
	
	if ( $count == 2 && $corp_key ne 'prr' ) {
		$corp->set_par_price( $par );
	}
	
	$game->log_event( 'Player $pid spends $total to purchase $count shares of $corp_key from the bank' );
	
	check_for_new_ceo( $game, $player, $corp_key );
	
	if ( $corp->share_count() <= 4 ) {
		$corp->set_cash( $value * 10 );
		$corp->set_current_price( $value );
		$corp->set_current_position( par_positions( $value ) );
		$game->adjust_cash( - ( $value * 10 ) );
		$game->log_event( "Corp $corp is floated at a price of $value with a treasury of " . $value * 10 );
	}
	
	$game->tick_stock_stamp();
	
	$game->clear_player_pass( $pid );
	$game->save_state();
	
	return 'ok';	
}


#############################################################################

sub _buy_market {
	my $game		= shift;
	my $r_args		= shift;
	
	my $pid = $r_args->{'pid'};
	my $player = $game->players()->[ $pid ];
	
	my $count = $r_args->{'count'};
	
	if ( $count < 1 ) {
		$count = 1;
	}
	
	my $corp_key = $r_args->{'corp'};
	
	if ( $game->share_count( $corp_key ) < $count ) {
		return 'error:Market Contains Insufficient Shares';
	}
	
	my $corp = $game->corps()->{ $corp_key };
	
	if ( $count > $corp->max_in_a_purchase() ) {
		return 'error:May Only Purchase One Share';
	}
	
	if ( $count + $player->total_certificate_count() > maximum_player_certificates( $game->number_of_players() ) ) {
		return 'error:Too Many Certificates';
	}

	if ( $player->did_sell_this_round( $corp_key ) == 1 ) {
		return 'error:Sold This Round';
	}

	my $value = $game->corps()->{ $corp_key }->get_current_price();

	if ( $player->get_cash() < $value * $count ) {
		return 'error:Not Enough Cash';
	}
	
	my $total = $value * $count;

	$player->add_shares( $corp_key, $count );
	$game->remove_shares( $corp_key, $count );
	
	$player->add_to_bought_this_round( $corp_key );

	$player->adjust_cash( - $total );
	$game->adjust_cash( $total );
	
	$game->log_event( "Player $pid spends $total to purchase $count shares of $corp_key from the market" );

	check_for_new_ceo( $game, $player, $corp_key );
	
	$game->tick_stock_stamp();
	
	$game->clear_player_pass( $pid );
	$game->save_state();
	
	return 'ok';	
}

#############################################################################

sub _sell {
	my $game		= shift;
	my $r_args		= shift;
	
	my $pid = $r_args->{'pid'};
	my $player = $game->players()->[ $pid ];
	
	my $corp_key = $r_args->{'corp'};
	
	if ( $player->holds_share( $corp_key ) == 0 ) {
		return 'error:No Shares Owned';
	}
	
	my $count = $r_args->{'count'};
	
	if ( $count < 1 ) {
		return 'error:Count Not Positive';
	}

	if ( $count > $player->share_count( $corp_key ) ) {
		return 'error:Not Enough Shares';
	}
	
	if ( $player->did_buy_this_round( $corp_key ) == 1 ) {
		return 'error:Bought This Round';
	}
	
	if ( $count + $game->share_count( $corp_key ) > 5 ) {
		return 'error:Too Many Shares In Bank';
	}
	
	my $new_ceo_pid = -1;
	if ( $player->is_ceo_of( $corp_key ) == 1 ) {
	
		my $max_count = 0;
		foreach my $t_pid ( $game->all_player_ids() ) {
			if ( $t_pid != $pid ) {
				my $other_count = $game->players()->[ $t_pid ]->share_count( $corp_key );
				if ( $other_count > 1 && $other_count > $max_count ) {
					$new_ceo_pid = $t_pid;
				}
			}
		}
	
		if ( $new_ceo_pid == -1 ) {
			return 'error:No Other CEO Candidate';
		}
	}
	

	my $value = $game->corps()->{ $corp_key }->get_current_price();
	
	$player->remove_shares( $corp_key, $count );
	$game->add_shares( $corp_key, $count );
	
	$player->add_to_sold_this_round( $corp_key );
	
	my $total = $value * $count;
	
	$game->log_event( "Player $pid sells $count shares of $corp_key at a price of $value each for $value" );

	$player->adjust_cash( $total );
	$game->adjust_cash( - $total );
	
	$game->log_event( "Player $pid gains $total" );
	
	if ( $game->get_cash() == 0 ) {
		$game->set_next_phase( 8 );
		$game->log_event( "Bank is broke" );
	}
	
	foreach ( 0 .. $count - 1 ) {
		if ( $game->corps()->{ $corp_key }->move_stock_down() == 1 ) {
			$game->log_event( "Market price for $corp_key is now " . $game->corps()->{ $corp_key }->get_current_price() );
		}
	}
	
	if ( $new_ceo_pid != -1 ) {
		$game->players()->[ $pid ]->make_ceo_of( $corp_key );
		$game->log_event( "Player $pid is now CEO of $corp_key" );
	}
	
	$game->tick_stock_stamp();
	
	$game->clear_player_pass( $pid );
	$game->save_state();
	
	return 'ok';	
}

#############################################################################

sub _done {
	my $game		= shift;
	my $r_args		= shift;
	
	my $pid = $r_args->{'pid'};
	my $player = $game->players()->[ $pid ];
	
	if ( $player->did_buy_or_sell() == 1 ) {
		$game->log_event( "Player $pid has finished their turn." );
	}
	else {
	
		$game->set_player_pass( $pid );
		$game->log_event( "Player $pid has passed." );
		
		if ( $game->have_all_passed() == 1 ) {
			$game->log_event( "All Players have passed." );
			return end_stock_round( $game );
		}
	}
		
	$game->next_player();
	$game->save_state();
	
	return 'ok';	
}


#############################################################################

sub _exchange_mh {
	my $game		= shift;
	my $r_args		= shift;
	
	my $pid = $r_args->{'pid'};
	my $player = $game->players()->[ $pid ];
	my $corp_key = 'nyc';
	my $private = '3_mh';
	my $corp = $game->corps()->{ $corp_key };
	
	if ( $player->holds_private( $private ) == 0 ) {
		return "error:Not Holder of $private";
	}
	
	my $location = $r_args->{'location'};
	
	if ( $location eq 'bank' ) {
		if ( $corp->share_count() < 1 ) {
			return "error:No Shares of $corp_key available in the bank.";
		}
	}
	elsif ( $location eq 'market' ) {
		if ( $game->share_count( $corp_key ) < 1 ) {
			return "error:No Shares of $corp_key available in the market.";
		}
	}
	else {
		return 'error:Invalid location';
	}
	
	if ( $player->total_certificate_count() + 1 > maximum_player_certificates( $game->number_of_players() ) ) {
		return 'error:Too Many Certificates';
	}

	$player->add_shares( $corp_key, 1 );
	$player->remove_private( $private );
	
	if ( $location eq 'bank' ) {
		$corp->remove_shares( $corp_key, 1 );
	}
	else {
		$game->remove_shares( $corp_key, 1 );
	}
	
	$game->log_event( "Player $pid exchanged $private for 1 share of $corp_key from $location" );

	check_for_new_ceo( $game, $player, $corp_key );
	
	$game->tick_stock_stamp();
	
	$game->save_state();
	
	return 'ok';		
}


#############################################################################
#############################################################################

sub end_stock_round {
	my $game		= shift;

	$game->clear_pass_flags();

	# Check to see if any floated corps move up
	
	foreach my $corp_key ( $game->corp_keys() ) {
		if ( $game->corps()->{ $corp_key }->share_count( $corp_key ) == 0 ) {
			if ( $game->share_count( $corp_key ) == 0 ) {
				if ( $game->corps()->{ $corp_key }->move_stock_up() == 1 ) {
					$game->log_event( 
						"Market price for $corp_key increases to " 
							. $game->corps()->{ $corp_key }->get_current_price() 
							. " due to all shares held" );
				}
			}
		}	
	}
	
	# Start operating round
	
	$game->set_current_round( 1 );
	$game->setup_corp_turns();
	$game->log_event( "Operating Round 1 Begins -----" );
	
	
	$game->pay_privates();	
	
	
	my $next_corp = $game->current_corp();
	
	# Are there any floated corps ?
	
	if ( $next_corp ne '' ) {
		# Yes
		
		$game->log_event( "Waiting on $next_corp" );
	}
	else {
		# No
		
		$game->set_current_round( 0 );
		$game->log_event( "Stock Round Begins -----" );
		$game->next_player();
	}
	
	$game->save_state();

	return 'ok';
}

#############################################################################

sub check_for_new_ceo {
	my $game		= shift;
	my $player		= shift;
	my $corp_key	= shift;
	
	my $old_ceo_pid = $game->ceo_of_corp( $corp_key );
	
	if ( $old_ceo_pid == $player->get_id() ) {
		return;
	}
	
	if ( $player->share_count( $corp_key ) > $game->players()->[ $old_ceo_pid ]->share_count( $corp_key ) ) {
		$game->players()->[ $old_ceo_pid ]->remove_as_ceo( $corp_key );
		$player->make_ceo_of( $corp_key );

		$game->log_event( "Player " . $player->get_id() . " is now CEO of $corp_key" );
	}
	
	return;
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

sub maximum_player_certificates {
	my $count		= shift;
	
	my %limits = (
		'2'		=> 28,
		'3'		=> 20,
		'4'		=> 16,
		'5'		=> 13,
		'6'		=> 11,
	);
	
	if ( defined( $limits{ $count } ) ) {
		return $limits{ $count };
	}
	
	return 0;
}

#############################################################################
#############################################################################
