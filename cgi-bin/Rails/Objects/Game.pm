package Rails::Objects::Game;

use strict;
use warnings;


my %_privates = (
	'0_sv'		=> { 'name' => 'Schuylkill Valley', 'cost' => 20, 'revenue' => 5 },
	'1_cs'		=> { 'name' => 'Champlain & St. Lawrence', 'cost' => 40, 'revenue' => 10 },
	'2_dh'		=> { 'name' => 'Delaware & Hudson', 'cost' => 70, 'revenue' => 15 },
	'3_mh'		=> { 'name' => 'Mohawk & Hudson', 'cost' => 110, 'revenue' => 20 },
	'4_ca'		=> { 'name' => 'Camden & Amboy', 'cost' => 160, 'revenue' => 25 },
	'5_bo'		=> { 'name' => 'Baltimore & Ohio', 'cost' => 220, 'revenue' => 30 },
);

$_privates{ '0_sv' }->{'description'} = '';
$_privates{ '1_cs' }->{'description'} = 'A railroad owning the CS may lay a tile on the CS’s hex (B-20). This hex need not be connected to one of the railroad’s stations, and it need not be connected to any track at all. This tile placement may be performed in addition to the railroad’s normal tile placement—on that turn only it may play two tiles';
$_privates{ '2_dh' }->{'description'} = 'A railroad owning the DH may lay a track tile and a station token on the DH’s hex (F-16). The mountain costs $120 as usual, but laying the token is free. This hex need not be connected to one of the railroad’s stations, and it need not be connect to any track at all. The tile laid does count as the owning railroad’s one tile placement for his turn. If the DH does not lay a station token on the turn it lays the tile on its starting hex, it must follow the normal rules when placing a station (i.e., it must have a legal train route to the hex). Other railroads may lay a tile on the DH starting hex subject to the ordinary rules, after which the DH special effects are no longer available.';
$_privates{ '3_mh' }->{'description'} = 'A player owning the MH may exchange it for a 10% share of NYC, provided he does not already hold 60% of the NYC shares and there is NYC shares available in the bank or the pool. The exchange may be made during the player’s turn of a stock round or between the turns of other players or railroads in either stock or operating rounds. This action closes the MH.';
$_privates{ '4_ca' }->{'description'} = 'The initial purchaser of the CA immediately receives a 10% share of PRR shares without further payment. This action does not close the CA. The PRR railroad will not be running at this point, but the shares may be retained or sold subject to the ordinary rules of the game.';
$_privates{ '5_bo' }->{'description'} = 'The owner of the BO private company immediately receives the president’s certificate of the B&O railroad without further payment and immediately sets a par share value. The BO private company may not be sold to any corporation, and does not change hands if the owning player loses the presidency of the B&O. When the B&O railroad purchases its first train this private company is closed down.';


my $_starting_bank	= 12000;

################

{
	use Object::InsideOut qw( Rails::Objects::Holder );
	use Rails::Objects::Map;
	use Rails::Objects::Corp;
	use Rails::Objects::Player;
	
	my @game_name		:Field	:Default( '' )				:Std(game_name);
	
	my @map				:Field	:Default( undef )			:Get(map);
	my @current_phase	:Field	:Default( 0 )				:Std(current_phase);
	my @next_phase		:Field	:Default( 0 )				:Std(next_phase);
	
	my @current_round	:Field	:Default( 0 )				:Std(current_round);
	
	my @current_player	:Field	:Default( 0 ) 				:Std(current_player_id);
	my @priority_player	:Field	:Default( 0 )				:Std(priority_player_id);
	
	my @corps			:Field	:Default( undef )			:Get(corps);
	my @corp_turns		:Field	:Default( undef )			:Get(corp_turns);
	
	my @player_count	:Field	:Default( 0 )				:Get(number_of_players);
	my @players			:Field	:Default( undef )			:Get(players);
	my @auction_players	:Field	:Default( undef )			:Get(auction_players);
	
	my @new_trains		:Field	:Default( undef )			:Get(new_trains);
	
	my @depreciation	:Field	:Default( 0 )				:Std(depreciation);
	
	
	#############################################

	sub _pre_init :PreInit {
		my ( $self, $args ) = @_;
		
		$args->{'game'} = $self;
		
		return;     
	}

	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		my $args	= shift;
		
		$self->set_doctype( 'Game' );
		
		$self->set( \@game_name, '' );
		$self->set( \@corps, {} );
		$self->set( \@corp_turns, [] );
		$self->set( \@player_count, 0 );
		$self->set( \@players, [] );
		$self->set( \@new_trains, [] );
		$self->set( \@current_player, 0 );
		$self->set( \@priority_player, 0 );
		$self->set( \@depreciation, 0 );
		$self->set( \@auction_players, [] );
		
		
		$self->set( \@map, Rails::Objects::Map->new( 'connection' => $self->connection(), 'game' => $self ) );
		$self->map()->load();

		my @corp_records = $self->connection()->sql( "SELECT id FROM corps" );

		foreach my $record ( @corp_records ) {
			my $corp = Rails::Objects::Corp->new( 'connection' => $self->connection(), 'game' => $self  );
			$corp->load( $record->{'id'} );
			$self->corps()->{ $record->{'id'} } = $corp;
		}

		$self->set_current_phase( 3 ); # test only 
		
		return;
	}
	
	#############################################

	sub clear {
		my $self 	= shift;


		
		
		$self->Rails::Objects::Base::clear();
		
		return;
	}

	#############################################

	sub new_game {
		my $self			= shift;
		my $game_id			= shift;
		my $player_count	= shift;
		
		$self->set_id( $game_id );
		$self->set_depreciation( 0 );
		
		$self->log_event( 'Created game with id: ' . $game_id );
		
		$self->set_game_name( random_name() );
		$self->log_event( 'Set game name as "' . $self->get_game_name() . '"' );
		
		$self->map()->create_state( $self->get_id() );
		$self->log_event( 'Created initial map state.' );

		foreach my $corp_key ( keys( %{ $self->corps() } ) ) {
			$self->corps()->{ $corp_key }->create_state( $game_id );
			$self->log_event( 'Created corporation: ' . $self->corps()->{ $corp_key }->get_long_name() );
		}
		
		$self->add_private( $self->all_private_keys() );
		$self->log_event( 'Added Private Companies' );
		
		push( @{ $new_trains[ $$self ] }, '2', '2', '2', '2', '2', '2' );
		$self->log_event( 'Added Initial Trains' );

		$self->adjust_cash( $_starting_bank - 2400 );
		$self->log_event( 'Initialzed Bank :' . $self->get_cash() );		
		
		my $player_cash = 2400 / $player_count;
		
		$self->set( \@player_count, $player_count );
		my @player_ids = ( 0 .. $player_count - 1 );
		
		foreach my $i ( @player_ids ) {
			my $player = Rails::Objects::Player->new( 'connection' => $self->connection(), 'game' => $self );
			$player->set_id( $i );
			$player->adjust_cash( $player_cash );
			$player->create_state( $self->get_id() );
			push( @{ $self->players() }, $player );
			$self->connection->sql( "INSERT INTO state_change_stamps ( game_id, stamp_name, stamp_value ) VALUES ( ?, 'player_$i', 0 ) ",	$self->get_id() );
			
			$self->log_event( 'Created Player [' . $i . '] with current cash: ' . $player->get_cash() );
			
		}

		$self->set_current_phase( -1 );
		$self->set_next_phase( -1 );
		$self->set_current_round( 0 );		
		
		$self->log_event( 'Set initial state to first stock round to purchase private companies.' );
		
		$self->set_current_player_id( $player_ids[ rand @player_ids ] );
		$self->set_priority_player_id( $self->get_current_player_id() );
		$self->log_event( 'Player ' . $self->get_current_player_id() . ' is first.' );
		
		
		$self->connection()->sql( 
			"INSERT INTO state_game ( id, cash, shares, privates, trains, game_name, new_trains,
			current_phase, next_phase, current_round, current_player, prioritydeal_player, player_count, corp_turns )
			VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '' )",
			$self->get_id(),
			$self->get_cash(), $self->shares_text(), $self->privates_text(), $self->trains_text(),
			$self->get_game_name(), join( ',', @{ $self->new_trains() } ),
			$self->get_current_phase(), $self->get_next_phase(), 
			$self->get_current_round(), $self->get_current_player_id(),
			$self->get_priority_player_id(), $self->number_of_players(),
		);
		
		$self->connection->sql( "INSERT INTO state_change_stamps ( game_id, stamp_name, stamp_value ) VALUES ( ?, 'map', 0 ) ",	$self->get_id() );
		$self->connection->sql( "INSERT INTO state_change_stamps ( game_id, stamp_name, stamp_value ) VALUES ( ?, 'market', 0 ) ",	$self->get_id() );
		$self->connection->sql( "INSERT INTO state_change_stamps ( game_id, stamp_name, stamp_value ) VALUES ( ?, 'auction', 0 ) ",	$self->get_id() );
		
		$self->log_event( 'Saved Game State' );
		

		return;		
	}



	#############################################

	sub load_state {
		my $self		= shift;
		my $game_id		= shift;
		
		my @records = $self->connection()->sql(
			"SELECT * FROM state_game WHERE id=?",
			$game_id,
		);
		
		unless ( @records ) {
			return 0;
		}
		
		my $record = shift( @records );
		
		$self->set_id( $game_id );

		$self->set_game_name( $record->{'game_name'} );
		$self->set_cash( $record->{'cash'} );
		$self->set_current_phase( $record->{'current_phase'} );
		$self->set_current_round( $record->{'current_round'} );
		$self->set_next_phase( $record->{'next_phase'} );
		$self->set_current_player_id( $record->{'current_player'} );
		$self->set_priority_player_id( $record->{'prioritydeal_player'} );
		$self->set( \@player_count, $record->{'player_count'} );

		push( @{ $self->new_trains() }, split( /,/, $record->{'new_trains'} ) );
		push( @{ $self->auction_players() }, split( /,/, $record->{'auction_players'} ) );
		push( @{ $self->corp_turns() }, split( /,/, $record->{'corp_turns'} ) );
		
		$self->set_depreciation( $record->{'depreciate_private'} );

		$self->privates_from_text( $record->{'privates'} );
		$self->trains_from_text( $record->{'trains'} );
		
		$self->map()->load_state( $self->get_id() );
		
		foreach my $corp_key ( keys( %{ $self->corps() } ) ) {
			$self->corps()->{ $corp_key }->load_state( $self->get_id() );
		}
		
		foreach my $i ( 0 .. $self->number_of_players() - 1 ) {
			my $player = Rails::Objects::Player->new( 'connection' => $self->connection(), 'game' => $self );
			$player->set_id( $i );
			$player->load_state( $self->get_id() );
			push( @{ $self->players() }, $player );
		}

		return 1;
	}
	
	
	#############################################

	sub save_state {
		my $self		= shift;

		$self->map()->save_state( $self->get_id() );

		foreach my $corp_key ( keys( %{ $self->corps() } ) ) {
			$self->corps()->{ $corp_key }->save_state( $self->get_id() );
		}

		foreach my $player ( @{ $self->players() } ) {
			$player->save_state( $self->get_id() );
		}
		
		$self->connection()->sql(
			"UPDATE state_game SET
			cash=?, shares=?, privates=?, trains=?,
			current_phase=?, next_phase=?, current_round=?,
			current_player=?, game_name=?, prioritydeal_player=?,
			new_trains=?, auction_players=?,
			depreciate_private=?, corp_turns=?
			WHERE id=?",

			$self->get_cash(), $self->shares_text(), $self->privates_text(), $self->trains_text(),
			$self->get_current_phase(), $self->get_next_phase(), 
			$self->get_current_round(), $self->get_current_player_id(), $self->get_game_name(),
			$self->get_priority_player_id(), 
			join( ',', @{ $self->new_trains() } ), join( ',', @{ $self->auction_players() } ),
			$self->get_depreciation(), join( ',', @{ $self->corp_turns() } ), 
			$self->get_id()
		);
				
		return;
	}

	#############################################
	
	sub corp_keys {
		my $self		= shift;
		
		return keys( %{ $self->corps() } );
	}

	#############################################

	sub current_corp {
		my $self		= shift;
		
		if ( scalar( @{ $self->get_corp_turns() } ) == 0 ) {
			return '';
		}
		
		return $self->get_corp_turns()->[ 0 ];
	}

	#############################################

	sub setup_corp_turns {
		my $self		= shift;
		
		my @floated_corps = ();
		
		foreach my $corp_key ( $self->corp_keys() ) {
			if ( $self->corps()->{ $corp_key }->share_count( $corp_key ) <= 4 ) {
				push( @floated_corps, $corp_key );
			}	
		}

		@floated_corps = sort {
			$b->get_current_price() <=> $a->get_current_price()
			||
			$b->price_column() <=> $a->price_column()
			||
			$a->price_row() <=> $b->price_row()
			||
			$a->get_current_index() <=> $b->get_current_index()	
		} @floated_corps;

		$self->set( \@corp_turns, \@floated_corps );
		
		return;
	}	

	#############################################

	sub first_private {
		my $self		= shift;
		
		my @p_keys = $self->private_keys();
		
		unless ( @p_keys ) {
			return '';
		}
		
		return shift( @p_keys );
	}

	#############################################

	sub all_private_keys {
		my $self		= shift;
	
		return sort( keys( %_privates ) );
	}

	#############################################

	sub private_revenue {
		my $self		= shift;
		my $private		= shift;
	
		if ( defined( $_privates{ $private } ) ) {
			return $_privates{ $private }->{'revenue'};
		}
	
		return 0;
	}
		
	#############################################

	sub private_cost {
		my $self		= shift;
		my $private		= shift;
		
		my $cost = 0;
	
		if ( defined( $_privates{ $private } ) ) {
			$cost = $_privates{ $private }->{'cost'};
		}
		
		if ( $private eq '0_sv' && $cost > 0 ) {
			$cost -= $self->get_depreciation() * 5;
		}
		
		return $cost;
	}

	#############################################

	sub private_name {
		my $self		= shift;
		my $private		= shift;
	
		if ( defined( $_privates{ $private } ) ) {
			return $_privates{ $private }->{'name'};
		}
	
		return '';
	}

	#############################################

	sub private_flavor {
		my $self		= shift;
		my $private		= shift;
		
		if ( defined( $_privates{ $private } ) ) {
			return $_privates{ $private }->{'description'};
		}
	
		return '';
	}
		

	#############################################

	sub player_ids_for_auction {
		my $self		= shift;
		my $private		= shift;
	
		return $self->connection()->simple_list(
			"SELECT player_id AS value FROM state_auction WHERE
			game_id=? AND private_id=?",
			$self->get_id(), $private
		);
	}

	#############################################

	sub minimum_bid_for_auction {
		my $self		= shift;
		my $private		= shift;
		
		my $high = $self->connection()->simple_value(
			0,
			"SELECT bid AS value FROM state_auction WHERE
			game_id=? AND private_id=? ORDER BY bid DESC",
			$self->get_id(), $private
		);
		
		if ( $high > 0 ) {
			return $high;
		}
		
		return $self->private_cost( $private ) + 5;
	}

	#############################################

	sub set_player_pass {
		my $self		= shift;
		my $player_id	= shift;
		
		$self->players()->[ $player_id ]->set_pass_flag( 1 );
		
		return;
	}

	#############################################

	sub clear_player_pass {
		my $self		= shift;
		my $player_id	= shift;
		
		$self->players()->[ $player_id ]->set_pass_flag( 0 );
		
		return;
	}

	#############################################

	sub have_all_passed {
		my $self		= shift;
		
		my $flag = $self->connection()->simple_value(
			0,
			"SELECT COUNT( player_id ) AS value FROM state_players WHERE pass_flag=0 AND game_id=?",
			$self->get_id(),
		);
		
		if ( $flag > 0 ) {
			return 0;
		}
		
		return 1;
	}

	#############################################

	sub clear_pass_flags {
		my $self	= shift;
		
		$self->connection()->simple_exec( 
			"UPDATE state_players SET pass_flag=0 WHERE game_id=?",
			$self->get_id(),
		);
		
		return;
	}

	#############################################

	sub next_player {
		my $self		= shift;
		
		my $current = $self->get_current_player_id();
		
		my @player_ids = $self->all_player_ids();
		
		my $next = -1;
		while ( $next == -1 ) {
			push( @player_ids, shift( @player_ids ) );
			if ( $player_ids[ 0 ] == $current ) {
				$next = $player_ids[ 1 ];
			}
		}
		
		$self->set_current_player_id( $next );
		$self->log_event( "Now Waiting on Player " . $self->get_current_player_id() );
		
		return $self->get_current_player_id();
	}

	#############################################

	sub next_priority_player_id {
		my $self		= shift;
		
		my $current = $self->get_current_player_id();
		
		my @player_ids = $self->all_player_ids();
		
		my $next = -1;
		while ( $next == -1 ) {
			push( @player_ids, shift( @player_ids ) );
			if ( $player_ids[ 0 ] == $current ) {
				$next = $player_ids[ 1 ];
			}
		}
		
		$self->set_priority_player_id( $next );
		$self->log_event( "Priority Deal passes to Player " . $self->get_priority_player_id() );
		
		return;
	}		

	#############################################

	sub all_player_ids {
		my $self		= shift;
		
		return ( 0 .. $self->number_of_players() - 1 );
	}

	#############################################

	sub certificate_limit {
		my $self		= shift;
		
		return maximum_player_certificates( $self->number_of_players() );
	}
	
	#############################################

	sub pay_privates {
		my $self		= shift;
		
		foreach my $player ( @{ $self->players() } ) {
			foreach my $private ( $player->private_keys() ) {
				my $amount = $_privates{ $private }->{'revenue'};
				$player->adjust_cash( $amount );
				$self->log_event( "Player " . $player->get_id() . " receives revenue from $private : $amount" );
			}
		}
		
		foreach my $corp_key ( keys( %{ $self->corps() } ) ) {
			foreach my $private ( $self->corps()->{ $corp_key }->private_keys() ) {
				my $amount = $_privates{ $private }->{'revenue'};
				$self->corps()->{ $corp_key }->adjust_cash( $amount );
				$self->log_event( "Company $corp_key receives revenue from $private : $amount" );
			}
		}
	
		return;
	}

	#############################################

	sub log_event {
		my $self		= shift;
		my $message		= shift;
		
		log_game_event( $self->get_id(), $message );
		
		return;
	}
	
	#############################################

	sub tick_map_stamp {
		my $self		= shift;
		
		$self->connection()->sql(
			"UPDATE state_change_stamps SET stamp_value = stamp_value + 1
			WHERE game_id=? AND stamp_name='map'",
			$self->get_id()
		);
		
		return;
	}

	#############################################

	sub tick_auction_stamp {
		my $self		= shift;
		
		$self->connection()->sql(
			"UPDATE state_change_stamps SET stamp_value = stamp_value + 1
			WHERE game_id=? AND stamp_name='auction'",
			$self->get_id()
		);
		
		return;
	}

	#############################################

	sub tick_market_stamp {
		my $self		= shift;
		
		$self->connection()->sql(
			"UPDATE state_change_stamps SET stamp_value = stamp_value + 1
			WHERE game_id=? AND stamp_name='market'",
			$self->get_id()
		);
				
		return;
	}

	#############################################

	sub tick_player_stamp {
		my $self		= shift;
		my $pid			= shift;
		
		$self->connection()->sql(
			"UPDATE state_change_stamps SET stamp_value = stamp_value + 1
			WHERE game_id=? AND stamp_name='player_$pid'",
			$self->get_id()
		);
				
		return;
	}

	#############################################

	sub tick_all_players_stamp {
		my $self		= shift;
		
		$self->connection()->sql(
			"UPDATE state_change_stamps SET stamp_value = stamp_value + 1
			WHERE game_id=? AND stamp_name LIKE 'player_%'",
			$self->get_id()
		);
		
		return;
	}

	#############################################

	sub ceo_of_corp {
		my $self		= shift;
		my $corp		= shift;
		
		foreach my $player ( @{ $self->players() } ) {
			if ( $player->is_ceo_of( $corp ) ) {
				return $player->get_id();
			}
		}
		
		return -1;
	}

	
	#############################################
	#############################################
	
}

#############################################################################

use List::Util qw( shuffle );

#############################################################################

sub new_game_id {
	
	my $string = '';
	my @chars = ( 'A' .. 'Z', 'a' .. 'z', '0' .. '9' );
	
	for ( 1 .. 12 ) {
		$string .= $chars[ rand @chars ];
	}

	return $string;
}

#############################################################################

sub random_name {
	
	my $word_list = '/usr/share/dict/words';
	
	my @words = ();
	
	unless ( open( WORDS, '<', $word_list ) ) {
		return new_game_id();
	}
	
	while ( my $word = <WORDS> ) {
		chomp( $word );
		push( @words, $word ) if ( length( $word ) == 6 );
	}
	
	close( WORDS );
	
	my @shuffled_words = shuffle( @words );
	
	return shift( @shuffled_words ) . ' ' . shift( @shuffled_words );
}

#############################################################################

sub all_games {
	my $connection	= shift;
	
	return $connection->sql( "SELECT id, game_name, current_phase FROM state_game" );
}


#############################################################################

sub log_game_event {
	my $gid		= shift;
	my $message	= shift;
	
	return;
	
	unless ( open( LOGFILE, '>>', 'log.' . $gid . '.txt' ) ) {
		print STDERR "Unable to open log file";
		return;
	}
	
	print STDERR "Opened log file";

	my $log = localtime(time) . ':' . $message;
	print LOGFILE "\n" . $log;
	
	close( LOGFILE );
	
	return;
}



#############################################################################
#############################################################################
1
