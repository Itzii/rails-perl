#!/usr/bin/perl

use strict;
use warnings;

use Rails::Methods::Database;


$| = 1;

use Test::More;

my $_server		= '';
my $_database	= 'test.sqlite';
my $_login		= '';
my $_password	= '';

my $_test_id	= 'TiXsVnVlCEB6';

my %_args = ();

foreach my $arg ( @ARGV ) {
	$_args{ $arg } = 1;
}


test_Base_Objects_Changeable();

my $connection = test_Base_Objects_Connection();

#if ( exists( $_args{'clean'} ) ) {

	print "\nDeleting previous test tables ... \n";
	delete_tables( $connection );

	print "\nCreating test tables ... \n";
	create_tables( $connection );

	print "\nSetting up dummy data ...\n";
	setup_dummy_data( $connection );
#}


test_Base_Methods_Session();

test_Rails_Objects_Route();
test_Rails_Objects_RouteList();

test_Base_Objects_Connectable( $connection );
test_Base_Objects_Base( $connection );
test_Base_Objects_Base_List( $connection );
test_Base_Objects_Screen( $connection );

test_Rails_Objects_Base( $connection );
test_Rails_Objects_Holder( $connection );
test_Rails_Objects_Player( $connection );
test_Rails_Objects_Corp( $connection );

test_Rails_Objects_Tile( $connection );
test_Rails_Objects_TileSet( $connection );

test_Rails_Objects_MapSpace( $connection );
test_Rails_Objects_Map( $connection );

test_Rails_Objects_Game( $connection );



test_Rails_Methods_Privates();


engine_testing( $connection );

done_testing();

if ( ! exists( $_args{'dirty'} ) ) {
#	clear_tables( $connection );
}

#############################################################################

sub fake {
	my $message		= shift;
	print " ... " . $message . "\n";
	
	return;
}

#############################################################################

sub show {
	my $message		= shift;
	
	print "\n+++ $message +++\n";
	
	return;
}

#############################################################################

sub setup_dummy_data {
	my $connection 	= shift;

	my %dummy = (
		'state_change_stamps' => {
			'count' => 10,
			'data' => 
				"INSERT INTO state_change_stamps ( id, game_id, stamp_name, stamp_value ) VALUES
					(52,'$_test_id','player_0',0),
					(53,'$_test_id','player_1',0),
					(54,'$_test_id','player_2',0),
					(55,'$_test_id','player_3',0),
					(56,'$_test_id','player_4',0),
					(57,'$_test_id','player_5',0),
					(58,'$_test_id','map',15),
					(59,'$_test_id','market',0),
					(60,'$_test_id','auction',0),
					(61,'','',0)
				",
		},
		
		'state_corps' => {
			'count' => 8,
			'data' =>
				"INSERT INTO state_corps ( id, game_id, corp_id, cash, trains, privates, stations, shares, par_price, current_price, current_index, current_position ) VALUES
					(1,'$_test_id','prr',0,'','','0,40,100,100','prr,10',0,0,0,'-1,-1'),
					(2,'$_test_id','cpr',0,'','','0,40,100,100','cpr,10',0,0,0,'-1,-1'),
					(3,'$_test_id','nyc',0,'','','0,40,100,100','nyc,10',0,0,0,'-1,-1'),
					(4,'$_test_id','bo',0,'','','0,40,100','bo,10',0,0,0,'-1,-1'),
					(5,'$_test_id','bm',0,'','','0,40','bm,10',0,0,0,'-1,-1'),
					(6,'$_test_id','nnh',0,'','','0,40','nnh,10',0,0,0,'-1,-1'),
					(7,'$_test_id','co',0,'','','0,40,100','co,10',0,0,0,'-1,-1'),
					(8,'$_test_id','erie',0,'','','0,40,100','erie,10',0,0,0,'-1,-1')
				",
		},
		
		'state_game' => {
			'count' => 1,
			'data' => 
				"INSERT INTO state_game ( id, cash, shares, privates, trains, current_phase, next_phase, current_round, current_player, game_name, prioritydeal_player, player_count, depreciate_private, auction_players, corp_turns, new_trains ) VALUES
					('$_test_id',9600,'','5_bo,4_ca,0_sv,1_cs,3_mh,2_dh','',-1,-1,0,5,'Test Game',5,6,0,'','','2,2,2,2,2,2')
				",
		},
		
		'state_players' => {
			'count' => 6,
			'data' => 
				"INSERT INTO state_players ( id, game_id, player_id, long_name, cash, shares, privates, running, pass_flag, sold, bought ) VALUES
					(1,'$_test_id',0,'Tom',400,'','','',0,'',''),
					(2,'$_test_id',1,'',400,'','','',0,'',''),
					(3,'$_test_id',2,'',400,'','','',0,'',''),
					(4,'$_test_id',3,'',400,'','','',0,'',''),
					(5,'$_test_id',4,'',400,'','','',0,'',''),
					(6,'$_test_id',5,'Sam',400,'','','',0,'','')
				",
		},
		
		'state_stations' => {
			'count' => 18,
			'data' =>
				"INSERT INTO state_stations ( id, game_id, space_id, station_id, slot_id, corp ) VALUES
					(865,'$_test_id','G19','city2',0,''),
					(866,'$_test_id','G19','city1',0,''),
					(867,'$_test_id','H18','city2',0,''),
					(868,'$_test_id','H18','city1',0,''),
					(869,'$_test_id','A19','city1',0,''),
					(870,'$_test_id','D14','city1',0,''),
					(871,'$_test_id','H12','city1',0,''),
					(872,'$_test_id','I15','city1',0,''),
					(873,'$_test_id','F6','city1',0,''),
					(874,'$_test_id','D10','city2',0,''),
					(875,'$_test_id','D10','city1',0,''),
					(876,'$_test_id','E11','city2',0,''),
					(877,'$_test_id','E11','city1',0,''),
					(878,'$_test_id','K15','city1',0,''),
					(879,'$_test_id','E23','city1',0,''),
					(880,'$_test_id','D2','city1',0,''),
					(881,'$_test_id','E5','city2',0,''),
					(882,'$_test_id','E5','city1',0,'')
				",
		},
		
		'state_tile_locations' => {
			'count' => 93,
			'data' =>
				"INSERT INTO state_tile_locations ( id, game_id, space_id, tile_id, orientation ) VALUES
					(11,'$_test_id','A9','-901',1),
					(12,'$_test_id','A11','-902',1),
					(13,'$_test_id','A17','-7',1),
					(14,'$_test_id','A19','-103',1),

					(15,'$_test_id','B10','-10',0),
					(16,'$_test_id','B12','0',0),
					(17,'$_test_id','B14','0',0),
					(18,'$_test_id','B16','-10',0),
					(19,'$_test_id','B18','0',0),
					(20,'$_test_id','B20','-1',0),
					(21,'$_test_id','B22','0',0),
					(22,'$_test_id','B24','-902',2),
					
					(23,'$_test_id','C7','0',0),
					(24,'$_test_id','C9','0',0),
					(25,'$_test_id','C11','0',0),
					(26,'$_test_id','C13','0',0),
					(27,'$_test_id','C15','-58',2),
					(28,'$_test_id','C17','0',0),
					(29,'$_test_id','C19','0',0),
					(30,'$_test_id','C21','0',0),
					(31,'$_test_id','C23','0',0),

					(32,'$_test_id','D2','-5',0),
					(33,'$_test_id','D4','58',5),
					(34,'$_test_id','D6','0',0),
					(35,'$_test_id','D8','0',0),
					(36,'$_test_id','D10','-20',0),
					(37,'$_test_id','D12','0',0),
					(38,'$_test_id','D14','-102',0),
					(39,'$_test_id','D16','0',0),
					(40,'$_test_id','D18','0',0),
					(41,'$_test_id','D20','0',0),
					(42,'$_test_id','D22','0',0),
					(43,'$_test_id','D24','-7',2),
					
					(44,'$_test_id','E3','46',2),
					(45,'$_test_id','E5','64',4),
					(46,'$_test_id','E7','-1',0),
					(47,'$_test_id','E9','-7',4),
					(48,'$_test_id','E11','59',0),
					(49,'$_test_id','E13','0',0),
					(50,'$_test_id','E15','0',0),
					(51,'$_test_id','E17','0',0),
					(52,'$_test_id','E19','-10',0),
					(53,'$_test_id','E21','0',0),
					(54,'$_test_id','E23','-11',5),

					(55,'$_test_id','F2','-903',5),
					(56,'$_test_id','F4','57',5),
					(57,'$_test_id','F6','-105',0),
					(58,'$_test_id','F8','8',4),
					(59,'$_test_id','F10','58',1),
					(60,'$_test_id','F12','0',0),
					(61,'$_test_id','F14','0',0),
					(62,'$_test_id','F16','-10',0),
					(63,'$_test_id','F18','0',0),
					(64,'$_test_id','F20','-2',0),
					(65,'$_test_id','F22','-10',0),
					(66,'$_test_id','F24','-3',2),

					(67,'$_test_id','G3','0',0),
					(68,'$_test_id','G5','26',0),
					(69,'$_test_id','G7','55',0),
					(70,'$_test_id','G9','0',0),
					(71,'$_test_id','G11','0',0),
					(72,'$_test_id','G13','0',0),
					(73,'$_test_id','G15','0',0),
					(74,'$_test_id','G17','-2',0),
					(75,'$_test_id','G19','-21',1),

					(76,'$_test_id','H2','7',4),
					(77,'$_test_id','H4','63',3),
					(78,'$_test_id','H6','24',1),
					(79,'$_test_id','H8','23',1),
					(80,'$_test_id','H10','57',1),
					(81,'$_test_id','H12','-101',0),
					(82,'$_test_id','H14','0',0),
					(83,'$_test_id','H16','-10',0),
					(84,'$_test_id','H18','-20',0),

					(85,'$_test_id','I3','16',0),
					(86,'$_test_id','I1','-901',5),
					(87,'$_test_id','I5','0',0),
					(88,'$_test_id','I7','0',0),
					(89,'$_test_id','I9','0',0),
					(90,'$_test_id','I11','0',0),
					(91,'$_test_id','I13','0',0),
					(92,'$_test_id','I15','-11',0),
					(93,'$_test_id','I17','0',0),
					(94,'$_test_id','I19','-3',2),


					(95,'$_test_id','J2','-902',5),
					(96,'$_test_id','J4','0',0),
					(97,'$_test_id','J6','0',0),
					(98,'$_test_id','J8','0',0),
					(99,'$_test_id','J10','0',0),
					(100,'$_test_id','J12','0',0),
					(101,'$_test_id','J14','-10',0),

					(102,'$_test_id','K13','-902',4),
					(103,'$_test_id','K15','-104',3)
				",
		},
	);
	
	foreach my $table_name ( sort( keys( %dummy ) ) ) {
		$connection->simple_exec( $dummy{ $table_name }->{'data'} );
		
		print "\nCreated test data for table $table_name ... ";
		
		my $count = $connection->simple_value( 0, "SELECT COUNT(*) AS value FROM $table_name" );
			
		if ( $dummy{ $table_name }->{'count'} > 0 ) {
			print "created $count records ... done.";
		}
		else {
			print "failed to create $count records.";
		}			
	}

	return;
}

#############################################################################

sub test_Base_Objects_Changeable {
	
	print "\nBase::Objects::Changeable ... \n";

	use Base::Objects::Changeable;

	my $base_1 = Base::Objects::Changeable->new();
	ok( defined( $base_1 ) && ref( $base_1 ) eq 'Base::Objects::Changeable', 'changeable object created' );

	
	ok( $base_1->has_changed() == 0, 'change flag is initially cleared' );
	
	$base_1->changed();
	ok( $base_1->has_changed() == 1, 'change flag can be tripped' );
	
	$base_1->clear_changed();
	ok( $base_1->has_changed() == 0, 'change flag can be cleared' );
	
	ok( $base_1->is_new() == 0, 'new flag is initially cleared' );
	
	$base_1->make_new();
	ok( $base_1->is_new() == 1, 'new flag can be set' );
	
	$base_1->not_new();
	ok( $base_1->is_new() == 0, 'new flag can be cleared' );


	
	return;
}

#############################################################################

sub test_Base_Objects_Connection {
	
	print "\nBase::Objects::Connection ... \n";
	
	use Base::Objects::Connection;

	my $connection = Base::Objects::Connection->new( 
		'error_callback' 	=> \&show,
		'bark_if_error'		=> 1,
		'server'			=> $_server,
		'database'			=> $_database,
		'login'				=> $_login,
		'password'			=> $_password,
	);

	ok( defined( $connection ) && ref( $connection ) eq 'Base::Objects::Connection', 'object created successfully' );
	
#	$connection->simple_exec( 'DROP TABLE junk' );	
	ok( $connection->simple_exec( 'CREATE TABLE junk ( id INT, junkfield VARCHAR(20), junkdate DATETIME )' ) || 1, 'creating test table' );
	
	ok( 
		$connection->simple_exec( 
			"INSERT INTO junk 
				( id, junkfield, junkdate )
			VALUES
				( 1, 'test1', date('now') ),
				( 2, 'test2', date('now') ),
				( 3, '', date('now') ),
				( 4, 'another value', date('now') ),
				( 5, 'another value', date('now') ),
				( 6, 'another value', '2012-02-01 12:00:45' )
			"
		) || 1,
		'added test values'
	);
	
#	ok( $connection->sql( 'SELECT name FROM test.sqlite_master WHERE type=\'table\'' ), 'table created successfully' );

	ok( $connection->simple_exec( 'UPDATE junk SET junkfield=? WHERE id=?', 'junk', 6 ) == 1, 'updating data with simple_exec' );
	
#	ok( $connection->check_for_value( 'SELECT junkfield FROM junk WHERE id=?' ) == 0, 'testing value field existance' );
	
	ok( $connection->simple_value( '', 'SELECT junkfield AS value FROM junk WHERE id=?', 1 ) eq 'test1', 'getting simple_value' );
	
	ok( $connection->simple_value( 'default', 'SELECT junkfield AS value FROM junk WHERE id=?', 9 ) eq 'default', 'returning default value' );

	my @list = ( 1, 2 );
#	my @list = $connection->simple_list( 
#		"SELECT id AS value FROM junk WHERE junkfield RLIKE '^test'", 
#	);
	
#	ok( scalar( @list ) == 2, 'getting simple_list' );
	
	@list = $connection->simple_add_to_list( 
		\@list, 
		'SELECT id AS value FROM junk WHERE junkfield=?', 
		'another value'
	);
	
	ok( scalar( @list ) == 4, 'adding to list' );
	
	my %data = $connection->simple_hash(
		'SELECT id AS keyfield, junkfield AS value FROM junk WHERE id<4',
	);
	
	ok( scalar( keys( %data ) ) == 3, 'getting simple hash' );
	
	%data = $connection->simple_add_to_hash(
		\%data,
		'SELECT id AS keyfield, junkfield AS value FROM junk WHERE id=5'
	);
	
	ok( scalar( keys( %data ) ) == 4, 'adding to hash' );
	
#	my $date = $connection->simple_date( 
#		undef,
#		"SELECT junkdate AS value FROM junk WHERE junkdate<'2013-01-01'",
#	);
	
#	ok( $date->as_sql() eq '2012-02-01 12:00:45', 'retrieved simple date' );

	
	$connection->sql( "INSERT INTO junk ( id, junkfield, junkdate ) VALUES ( 7, '', '0000-00-00 00:00:00' )" );
	$connection->duprecord( 'junk', 'id', 6, 7 );
#	$date = $connection->simple_date( undef, 'SELECT junkdate AS value FROM junk WHERE id=7' );
 #	ok( $date->as_sql() eq '2012-02-01 12:00:45', 'duplicated record' );
	
	$connection->duprecord( 'junk', 'id', 6, 2, 'junkfield' );
#	$date = $connection->simple_date( undef, 'SELECT junkdate AS value FROM junk WHERE id=2' );
# 	ok( $date->as_sql() eq '2012-02-01 12:00:45', 'duplicated record with exclusion' );
	ok( $connection->simple_value( '', 'SELECT junkfield AS value FROM junk WHERE id=2' ) eq 'test2', 'field excluded' );
	
	
	ok( $connection->safe_identifier( 'abcdeffff"333%%;1=1' ) eq 'abcdeffff33311', 'filter for safe identifier' );
	
	ok( $connection->simple_exec( 'DROP TABLE junk' ) || 1, 'test table removed' );
	
	return $connection;	
}

#############################################################################

sub test_Base_Methods_Session {

	print "\nBase::Methods::Session ... \n";
	
	use Base::Methods::Session;
	
	return;
}
	
#############################################################################
	
sub test_Base_Objects_Connectable {
	my $connection	= shift;
	
	print "\nBase::Objects::Connectable ... \n";
	
	use Base::Objects::Connectable;

	my $doctype 	= 'testdoc';
	my $id			= 987654;
	my $docnumber	= '0124567';

	my $base_1 = Base::Objects::Connectable->new( 'connection' => $connection, 'doctype' => $doctype );
	ok( defined( $base_1 ) && ref( $base_1 ) eq 'Base::Objects::Connectable', 'connectable object created' );
	
	ok( $base_1->get_doctype() eq $doctype, 'doctype is getable' );
	
	$base_1->clear();
	ok( 
		$base_1->is_valid() == 0 
		&& $base_1->get_id() == -1 
		&& $base_1->get_docnumber() eq '',
		'object is cleared' 
	);
	
	$base_1->clear_flags();
	ok( $base_1->is_valid() == 1, 'object flags are cleared' );
	$base_1->clear();
	
	$base_1->make_valid();
	ok( $base_1->is_valid() == 1, 'object can be made valid' );
	$base_1->clear();
	
	$base_1->set_id( $id );
	ok( $base_1->get_id() == $id, 'id is setable and getable' );
	$base_1->clear();

	$base_1->set_docnumber( $docnumber );
	ok( $base_1->get_docnumber() eq $docnumber, 'docnumber is setable and getable' );
	$base_1->clear();
	
	
	
	return;
}

#############################################################################

sub test_Base_Objects_Base {
	my $connection	= shift;
	
	print "\nBase::Objects::Base ... \n";
	
	use Base::Objects::Base;
	
	my $base_1 = Base::Objects::Base->new( 'connection' => $connection, 'doctype' => 'test_base_doc' );
	ok( defined( $base_1 ) && ref( $base_1 ) eq 'Base::Objects::Base', 'base object created' );
	
	
	return;
}
	
#############################################################################

sub test_Base_Objects_Base_List {
	my $connection		= shift;

	print "\nBase::Objects::Base_List ... \n";

	use Base::Objects::Base_List;

	my @test_items	= ( 'item_1', 'item_2', 'item_3', 'item_4', 'item_5' );
	my @other_items = ( 'item_x', 'item_y', 'item_z' );
	my $doctype 	= 'testdoc';

	my $list = Base::Objects::Base_List->new( 
		'connection' => $connection, 
		'doctype' => $doctype 
	);
	ok( defined( $list ) && ref( $list ) eq 'Base::Objects::Base_List', 'list object created' );
	
	ok( $list->count() == 0, 'list is empty' );
	
	ok( $list->has_changed() == 0, 'change flag is clear' );
	
	$list->add( 'item_0' );
	ok( $list->count() == 1 && $list->has_changed(), 'item added to list' );
	
	$list->add( @test_items );
	ok( $list->count() == 6, 'multiple items added to list' );
	
	$list->insert( 3, 'item_a' );
	ok( ($list->items())[ 3 ] eq 'item_a' && $list->count() == 7, 'item inserted at position' );
	
	$list->delete( 4 );
	ok( $list->count() == 6 && ($list->items())[ 4 ] eq 'item_4', 'item deleted at position' );
	
	$list->remove( 'item_0' );
	ok( $list->count() == 5 && ($list->items())[ 0 ] eq 'item_1', 'specific item removed' );
	
	my $list2 = Base::Objects::Base_List->new( 'doctype' => $doctype );
	$list->add( @other_items );

	$list->add_list( $list2 );
	ok( $list->count() == 8 && ($list->items())[ 7 ] eq 'item_z', 'list added to list' );
	
	$list->clear_flags();
	ok( $list->has_changed() == 0, 'flags cleared' );
	
	$list->add( \@test_items );
	ok( $list->index_of( \@test_items ) == 8, 'index of item returned' );
	
	
	return;
}

#############################################################################

sub test_Base_Objects_Screen {
	my $connection		= shift;

	print "\nBase::Objects::Screen ... \n";

	use Base::Objects::Screen;
	
	my $screen = Base::Objects::Screen->new( 
		'config' => 'test_config', 
		'type' => 'test', 
		'template' => 'test.html', 
		'connection' => $connection,
	);
	
	ok( defined( $screen ) && ref( $screen ) eq 'Base::Objects::Screen', 'screen object created' );
	
	$screen->set_arg( 'gid', 'test123' );
	ok( $screen->gid() eq 'test123', 'gid is readable' );
	
	$screen->set_arg( 'pid', '123test' );
	ok( $screen->pid() eq '123test', 'pid is readable' );
	
	$screen->set_arg( 'action', 'testaction' );
	ok( $screen->action() eq 'testaction', 'action is readable' );
	
	my $body = $screen->body();
	ok( $body =~ m{ test123 }xmsi, 'body text has vars replaced' );
	
	$screen->set_arg( 'action', 'stamp_value' );
	ok( $screen->process_action() eq 'ok:0', 'stamp value retrieved' );
	
	ok( $screen->money( 1000 ) eq '$1,000', 'money is formatted correctly' );
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Base {
	my $connection		= shift;
	
	print "\nRails::Objects::Base ... \n";
	
	use Rails::Objects::Base;
	
	my $base = Rails::Objects::Base->new( 'connection' => $connection );
	
	ok( defined( $base ) && ref( $base ) eq 'Rails::Objects::Base', 'rails base object created' );
	


	return;
}

#############################################################################

sub test_Rails_Objects_Holder {
	my $connection		= shift;
	
	print "\nRails::Methods::Holder ...\n";
	
	use Rails::Objects::Holder;
	
	my $holder = Rails::Objects::Holder->new( 'connection' => $connection, 'game' => 'junk' );
	
	ok( defined( $holder ) && ref( $holder ) eq 'Rails::Objects::Holder', 'holder object created' );
	
	$holder->set_cash( 100 );
	$holder->adjust_cash( 10 );
	ok( $holder->get_cash() == 110, 'cash set and adjusted correctly' );
	
	$holder->adjust_cash( -50 );
	ok( $holder->get_cash() == 60, 'cash decremented correctly' );
	
	$holder->add_private( 'p1', 'p2', 'p3' );
	ok( $holder->holds_private( 'p2' ) == 1, 'privates added and tested' );
	
	$holder->remove_private( 'p2' );
	ok( $holder->holds_private( 'p2' ) == 0 && $holder->holds_private( 'p3' ) == 1 , 'privates removed correctly' );
	
	my @test_list = sort( 'p1', 'p3' );
	my @current_list = $holder->private_keys();
	ok( @current_list ~~ @test_list, 'private keys returned correctly' );
	
	ok( $holder->privates_text() eq 'p1,p3', 'private text returned correctly' );
	
	$holder->privates_from_text( 'a1,a3,a2' );
	ok( $holder->privates_text() eq 'a1,a2,a3', 'privates parsed from text' );
	
	$holder->add_shares( 'a1', 2 );
	$holder->add_shares( 'b2', 3 );
	$holder->add_shares( 'c3', 6 );
	
	@test_list = sort( 'a1', 'b2', 'c3' );
	@current_list = $holder->share_keys();
	
	ok( @current_list ~~ @test_list, 'shares added and keys are correct' );
	
	ok( $holder->holds_share( 'b2' ) == 1 && $holder->holds_share( 'd4' ) == 0, 'holding share is determined correctly' );
	
	ok( $holder->share_count( 'c3' ) == 6, 'share count is correct' );
	
	$holder->remove_shares( 'c3', 2 );
	ok( $holder->share_count( 'c3' ) == 4, 'shares removed' );
	
	ok( $holder->shares_text() eq 'a1,2;b2,3;c3,4', 'share text is correct' );
	
	$holder->shares_from_text( 'a2,1;b3,5' );
	ok( $holder->share_count( 'b3' ) == 5, 'shares from text are correct' );
	
	$holder->trains_from_text( 'a,b,b,b,c' );
	ok( $holder->train_count() == 5, 'trains parsed from text and count is correct' );
	
	$holder->add_train( 'd' );
	ok( $holder->train_count() == 6, 'train added' );
	
	$holder->remove_train( 'c' );
	ok( $holder->train_count() == 5, 'train removed' );
	
	$holder->remove_train_type( 'b' );
	ok( $holder->train_count() == 2, 'train type removed' );
	
	ok( $holder->trains_text() eq 'a,d', 'train text is correct' );
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Player {
	my $connection		= shift;
	
	print "\nRails::Objects::Player ...\n";
	
	use Rails::Objects::Player;
	
	my $player = Rails::Objects::Player->new( 'connection' => $connection, 'game' => 'junk' );
	
	ok( defined( $player ) && ref( $player ) eq 'Rails::Objects::Player', 'player object created' );
	
	ok( $player->display_name() eq 'Player 1', 'display name is correct by default' );
	
	$player->set_long_name( 'Sam' );
	ok( $player->display_name() eq 'Sam', 'display name is correct after adjustment' );
	
	$player->clear_changed();
	$player->set_pass_flag( 1 );
	ok( $player->get_pass_flag() == 1 && $player->has_changed() == 1, 'pass flag is setable and getable' );
	
	$player->make_ceo_of( 'zzz' );
	ok( $player->is_ceo_of( 'zzz' ) == 1, 'ceo flag is setable' );
	ok( $player->is_ceo_of( 'aaa' ) == 0, 'ceo flag reads false correctly' );
	
	$player->remove_as_ceo( 'zzz' );
	ok( $player->is_ceo_of( 'zzz' ) == 0, 'removed as ceo' );
	
	ok( $player->did_buy_or_sell() == 0, 'nothing bought or sold yet' );
	
	ok( $player->did_buy_this_round( 'a1' ) == 0, 'not bought yet' );
	
	$player->add_to_bought_this_round( 'a1' );
	ok( $player->did_buy_this_round( 'a1' ) == 1, 'now bought' );
	
	ok( $player->did_buy_this_round( 'b2' ) == 0, 'something not bought' );
	
	ok( $player->did_sell_this_round( 'd1' ) == 0, 'not sold yet' );
	
	$player->add_to_sold_this_round( 'd1' );
	ok( $player->did_sell_this_round( 'd1' ) == 1, 'now sold' );
	
	ok( $player->did_sell_this_round( 'e2' ) == 0, 'something not sold' );
	
	ok( $player->did_buy_or_sell() == 1, 'something bought or sold' );
	
	$player->clear_bought_sold();
	ok( $player->did_buy_or_sell() == 0, 'something bought or sold is cleared' );
	
	$player = Rails::Objects::Player->new( 'connection' => $connection, 'game' => Base::Objects::Base->new( 'connection' => $connection ) );
	$player->create_state( 'testid' );
	
	ok( $player->load_state( 'testid' ) == 1, 'state loaded' );
	
	$player->set_long_name( 'Merry' );
	$player->save_state();
	
	
	
	
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Corp {
	my $connection		= shift;
	
	print "\nRails::Objects::Corp ...\n";
	
	use Rails::Objects::Corp;
	
	my $corp = Rails::Objects::Corp->new( 'connection' => $connection, 'game' => 'junk' );
	
	ok( defined( $corp ) && ref( $corp ) eq 'Rails::Objects::Corp', 'corp object created' );
	

	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Route {
	
	print "\nRails::Objects::Route ... \n";
	
	use Rails::Objects::Route;
	
	my $route = Rails::Objects::Route->new();
	
	ok( defined( $route ) && ref( $route ) eq 'Rails::Objects::Route', 'route object created' );
	

	$route->add_node( 'node1', 10 );
	$route->add_node( 'node5', 50 );
	$route->add_node( 'node3', 0 );
	$route->add_node( 'node4', 0 );
	$route->add_node( 'node2', 30 );

	show( $route->as_text() );

	my $route2 = Rails::Objects::Route->new();

	$route2->add_node( 'node5', 50 );
	$route2->add_node( 'node6', 0 );
	$route2->add_node( 'node7', 10 );
	$route2->add_node( 'node8', 20 );

	show( $route2->as_text() );
	ok( $route->contains_common_path( $route2 ) == 0, 'no common path' );

	my $route3 = Rails::Objects::Route->new();

	$route3->add_node( 'node5', 50 );
	$route3->add_node( 'node1', 10 );
	$route3->add_node( 'node9', 10 );
	$route3->add_node( 'node8', 0 );

	show( $route3->as_text() );
	ok( $route->contains_common_path( $route3 ) == 1, 'common path found' );


	print "\n" . join( ',', $route3->paths() ) . "\n";
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_RouteList {
	
	print "\nRails::Objects::RouteList ... \n";
	
	use Rails::Objects::RouteList;
	
	my $list = Rails::Objects::RouteList->new();
	
	ok( defined( $list ) && ref( $list ) eq 'Rails::Objects::RouteList', 'route list object created' );
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Tile {
	my $connection		= shift;
	
	print "\nRails::Objects::Tile ... \n";
	
	use Rails::Objects::Tile;
	
	my $tile = Rails::Objects::Tile->new( 'connection' => $connection );
	
	ok( defined( $tile ) && ref( $tile ) eq 'Rails::Objects::Tile', 'tile object created' );
	
	my @records = $connection->sql( "SELECT * FROM tiles WHERE tile_id=46" );
	
	ok( @records, 'tile record retrieved' );
	
	$tile->parse_from_record( $records[ 0 ] );
	
	ok( $tile->get_color() eq 'brown', 'tile color is correct' );
	
	ok( $tile->get_count() == 2, 'count is correct' );
	
	ok( $tile->get_name() eq '46', 'name is corrent' );
	
	my @nodes = sort( $tile->node_connects_to( 'side0' ) );
	
	ok( $nodes[ 0 ] eq 'side1' && $nodes[ 1 ] eq 'side3', 'node0 start connects to correct ends' );
	
	@nodes = sort( $tile->node_connects_to( 'side5' ) );
	
	ok( $nodes[ 0 ] eq 'side1' && $nodes[ 1 ] eq 'side3', 'node5 start connects to correct ends' );
	
	@records = $connection->sql( "SELECT * FROM tiles WHERE tile_id=57" );
	$tile->parse_from_record( $records[ 0 ] );
	
	ok( $tile->value_of_node( 'city1' ) == 20, 'node value is correct' );
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_TileSet {
	my $connection		= shift;
	
	print "\nRails::Objects::TileSet ... \n";
	
	use Rails::Objects::TileSet;
	
	my $tileset = Rails::Objects::TileSet->new( 'connection' => $connection );
	
	ok( defined( $tileset ) && ref( $tileset ) eq 'Rails::Objects::TileSet', 'tileset object created' );
	
	$tileset->load();
	
	my $tile = $tileset->tile( '46' );
	
	ok( $tile->get_name() eq '46', 'tileset loaded and tile retrieved' );
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_MapSpace {
	my $connection		= shift;
	
	print "\nRails::Objects::MapSpace ... \n";
	
	use Rails::Objects::MapSpace;
	
	my $tileset = Rails::Objects::TileSet->new( 'connection' => $connection );

	my $space = Rails::Objects::MapSpace->new( 'connection' => $connection, 'tile_set' => $tileset );
	
	ok( defined( $space ) && ref( $space ) eq 'Rails::Objects::MapSpace', 'mapspace object created' );
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Map {
	my $connection		= shift;
	
	print "\nRails::Objects::Map ... \n";
	
	use Rails::Objects::Map;
	
	my $map = Rails::Objects::Map->new( 'connection' => $connection, 'game' => 'junk' );
	
	ok( defined( $map ) && ref( $map ) eq 'Rails::Objects::Map', 'map object created' );
	
	$map->load_state( $_test_id );
	
	ok( $map->space( 'F2' )->get_tile_id() eq '-903', 'tile id retrieved from space' );
	
	my @nodes = sort( $map->node_connects_to( 'E3.side1' ) );
	my @test_list = ( 'E3.side3','E3.side5','E5.side4' );
	
	ok( @nodes ~~ @test_list, 'nodes connect to correct nodes' );
	
	
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Objects_Game {
	my $connection		= shift;
	
	print "\nRails::Objects::Game ... \n";
	
	use Rails::Objects::Game;
	
	my $game = Rails::Objects::Game->new( 'connection' => $connection );
	
	ok( defined( $game ) && ref( $game ) eq 'Rails::Objects::Game', 'game object created' );
	
	ok( $game->load_state( $_test_id ) == 1, 'game state says its loaded' );
	
	ok( $game->get_game_name() eq 'Test Game', 'name is loaded correctly' );
	
	ok( $game->get_cash() == 9600, 'cash is loaded correctly' );
	
	ok( $game->get_current_phase() == -1, 'current phase is loaded correctly' );
	
	ok( $game->get_current_round() == 0, 'current round is loaded correctly' );
	
	ok( $game->get_next_phase() == -1, 'next phase is loaded correctly' );
	
	ok( $game->get_current_player_id() == 5, 'current player id loaded correctly' );
	
	ok( $game->get_priority_player_id() == 5, 'priority player id loaded correctly' );
	
	
	
	
	
	
	
	
	
	return;
}

#############################################################################

sub test_Rails_Methods_Privates {
	my $connection		= shift;
	
	print "\nRails::Methods::Privates ... \n";
	
	use Rails::Methods::Privates;
	
	
	
	return;
}
		






#############################################################################

sub engine_testing {
	my $connection		= shift;
	
	my $game = Rails::Objects::Game->new( 'connection' => $connection );
	$game->load_state( $_test_id );
	
	my %cases = (
		'case 01:'  => { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '2', 'value' => '60' },
		'case 02:'  => { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '3', 'value' => '90' },
		'case 03:'  => { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '4', 'value' => '100' },
		'case 04:'  => { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '5', 'value' => '130' },
		'case 05:'  => { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '6', 'value' => '140' },
 		'case 06:'  => { 'start' => 'D2.city1', 'corp' => 'co', 'train' => '6', 'value' => '170' },
		'case 07:'	=> { 'start' => 'F4.city1', 'corp' => 'bo', 'train' => '6', 'value' => '170' },
 		'case 08:'  => { 'start' => 'D2.city1', 'corp' => 'bo', 'train' => '6', 'value' => '170' },
 		'case 09:'  => { 'start' => 'D2.city1', 'corp' => 'bo', 'train' => 'd', 'value' => '170' },
 		'case 10:'  => { 'start' => 'H10.city1', 'corp' => 'co', 'train' => 'd', 'value' => '210' },
	);

	foreach my $case_key ( sort( keys( %cases ) ) ) {

		my $route_list = $game->map()->routes_through_node(
			$cases{ $case_key }->{'start'},
			$cases{ $case_key }->{'train'},
			$cases{ $case_key }->{'corp'},
		);

		my $best_route = $route_list->best_not_matching();

		print "\nCase: $case_key - ";

		if ( $best_route->get_value() != $cases{ $case_key }->{'value'} ) {
			print "failed!";

			foreach my $route ( @{ $route_list->routes() } ) {
				print "\n " . $route->as_text();
			}

		}
		else {
			print "passed.";
		}

	}
	
	
	return;
}





