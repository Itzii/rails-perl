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
test_Base_Objects_Connectable( $connection );
test_Base_Objects_Base( $connection );
test_Base_Objects_Base_List( $connection );
test_Base_Objects_Screen( $connection );

test_Rails_Objects_Base( $connection );
test_Rails_Objects_Holder( $connection );



test_Rails_Methods_Privates();

done_testing();

if ( ! exists( $_args{'dirty'} ) ) {
	clear_tables( $connection );
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

	$connection->simple_exec(
		"INSERT INTO state_change_stamps ( id, game_id, stamp_name, stamp_value ) VALUES
			(52,'TiXsVnVlCEB6','player_0',0),
			(53,'TiXsVnVlCEB6','player_1',0),
			(54,'TiXsVnVlCEB6','player_2',0),
			(55,'TiXsVnVlCEB6','player_3',0),
			(56,'TiXsVnVlCEB6','player_4',0),
			(57,'TiXsVnVlCEB6','player_5',0),
			(58,'TiXsVnVlCEB6','map',15),
			(59,'TiXsVnVlCEB6','market',0),
			(60,'TiXsVnVlCEB6','auction',0),
			(61,'','',0)
		"
	);

	$connection->simple_exec(
		"INSERT INTO state_corps ( id, game_id, corp_id, cash, trains, privates, stations, shares, par_price, current_price, current_index, current_position ) VALUES
			(1,'TiXsVnVlCEB6','prr',0,'','','0,40,100,100','prr,10',0,0,0,'-1,-1'),
			(2,'TiXsVnVlCEB6','cpr',0,'','','0,40,100,100','cpr,10',0,0,0,'-1,-1'),
			(3,'TiXsVnVlCEB6','nyc',0,'','','0,40,100,100','nyc,10',0,0,0,'-1,-1'),
			(4,'TiXsVnVlCEB6','bo',0,'','','0,40,100','bo,10',0,0,0,'-1,-1'),
			(5,'TiXsVnVlCEB6','bm',0,'','','0,40','bm,10',0,0,0,'-1,-1'),
			(6,'TiXsVnVlCEB6','nnh',0,'','','0,40','nnh,10',0,0,0,'-1,-1'),
			(7,'TiXsVnVlCEB6','co',0,'','','0,40,100','co,10',0,0,0,'-1,-1'),
			(8,'TiXsVnVlCEB6','erie',0,'','','0,40,100','erie,10',0,0,0,'-1,-1')
		"
	);

	$connection->simple_exec(
		"INSERT INTO state_game ( id, cash, shares, privates, trains, current_phase, next_phase, current_round, current_player, game_name, prioritydeal_player, player_count, depreciate_private, auction_players, corp_turns, new_trains ) VALUES
			('TiXsVnVlCEB6',9600,'','5_bo,4_ca,0_sv,1_cs,3_mh,2_dh','',-1,-1,0,5,'3Yoc5W3oTgEo',5,6,0,'','','2,2,2,2,2,2')
		"
	);

	$connection->simple_exec(
		"INSERT INTO state_players ( id, game_id, player_id, long_name, cash, shares, privates, running, pass_flag, sold, bought ) VALUES
			(1,'TiXsVnVlCEB6',0,'Tom',400,'','','',0,'',''),
			(2,'TiXsVnVlCEB6',1,'',400,'','','',0,'',''),
			(3,'TiXsVnVlCEB6',2,'',400,'','','',0,'',''),
			(4,'TiXsVnVlCEB6',3,'',400,'','','',0,'',''),
			(5,'TiXsVnVlCEB6',4,'',400,'','','',0,'',''),
			(6,'TiXsVnVlCEB6',5,'Sam',400,'','','',0,'','')
		"
	);

	$connection->simple_exec(
		"INSERT INTO state_stations ( id, game_id, space_id, station_id, slot_id, corp ) VALUES
			(865,'TiXsVnVlCEB6','G19','city2',0,''),
			(866,'TiXsVnVlCEB6','G19','city1',0,''),
			(867,'TiXsVnVlCEB6','H18','city2',0,''),
			(868,'TiXsVnVlCEB6','H18','city1',0,''),
			(869,'TiXsVnVlCEB6','A19','city1',0,''),
			(870,'TiXsVnVlCEB6','D14','city1',0,''),
			(871,'TiXsVnVlCEB6','H12','city1',0,''),
			(872,'TiXsVnVlCEB6','I15','city1',0,''),
			(873,'TiXsVnVlCEB6','F6','city1',0,''),
			(874,'TiXsVnVlCEB6','D10','city2',0,''),
			(875,'TiXsVnVlCEB6','D10','city1',0,''),
			(876,'TiXsVnVlCEB6','E11','city2',0,''),
			(877,'TiXsVnVlCEB6','E11','city1',0,''),
			(878,'TiXsVnVlCEB6','K15','city1',0,''),
			(879,'TiXsVnVlCEB6','E23','city1',0,''),
			(880,'TiXsVnVlCEB6','D2','city1',0,''),
			(881,'TiXsVnVlCEB6','E5','city2',0,''),
			(882,'TiXsVnVlCEB6','E5','city1',0,'')
		"
	);
	
	$connection->simple_exec(
		"INSERT INTO state_tile_locations ( id, game_id, space_id, tile_id, orientation ) VALUES
			(3164,'TiXsVnVlCEB6','E15','0',0),
			(3165,'TiXsVnVlCEB6','F16','-10',0),
			(3166,'TiXsVnVlCEB6','I11','0',0),
			(3167,'TiXsVnVlCEB6','E13','0',0),
			(3168,'TiXsVnVlCEB6','E21','0',0),
			(3169,'TiXsVnVlCEB6','C11','0',0),
			(3170,'TiXsVnVlCEB6','J2','-902',5),
			(3171,'TiXsVnVlCEB6','I5','0',0),
			(3172,'TiXsVnVlCEB6','E9','-7',4),
			(3173,'TiXsVnVlCEB6','G7','55',0),
			(3174,'TiXsVnVlCEB6','G19','-21',1),
			(3175,'TiXsVnVlCEB6','D24','-7',2),
			(3176,'TiXsVnVlCEB6','D18','0',0),
			(3177,'TiXsVnVlCEB6','E7','-1',0),
			(3178,'TiXsVnVlCEB6','F8','8',4),
			(3179,'TiXsVnVlCEB6','H18','-20',0),
			(3180,'TiXsVnVlCEB6','H16','-10',0),
			(3181,'TiXsVnVlCEB6','A17','-7',1),
			(3182,'TiXsVnVlCEB6','B18','0',0),
			(3183,'TiXsVnVlCEB6','C17','0',0),
			(3184,'TiXsVnVlCEB6','A19','-103',1),
			(3185,'TiXsVnVlCEB6','H8','23',1),
			(3186,'TiXsVnVlCEB6','B10','-10',0),
			(3187,'TiXsVnVlCEB6','G11','0',0),
			(3188,'TiXsVnVlCEB6','J8','0',0),
			(3189,'TiXsVnVlCEB6','B14','0',0),
			(3190,'TiXsVnVlCEB6','D6','0',0),
			(3191,'TiXsVnVlCEB6','D20','0',0),
			(3192,'TiXsVnVlCEB6','C19','0',0),
			(3193,'TiXsVnVlCEB6','D14','-102',0),
			(3194,'TiXsVnVlCEB6','F2','-903',5),
			(3195,'TiXsVnVlCEB6','D8','0',0),
			(3196,'TiXsVnVlCEB6','B24','-902',2),
			(3197,'TiXsVnVlCEB6','E3','46',2),
			(3198,'TiXsVnVlCEB6','F24','-3',2),
			(3199,'TiXsVnVlCEB6','H12','-101',0),
			(3200,'TiXsVnVlCEB6','I15','-11',0),
			(3201,'TiXsVnVlCEB6','D22','0',0),
			(3202,'TiXsVnVlCEB6','J12','0',0),
			(3203,'TiXsVnVlCEB6','G13','0',0),
			(3204,'TiXsVnVlCEB6','H4','63',3),
			(3205,'TiXsVnVlCEB6','F6','-105',0),
			(3206,'TiXsVnVlCEB6','J10','0',0),
			(3207,'TiXsVnVlCEB6','D10','-20',0),
			(3208,'TiXsVnVlCEB6','C15','-58',2),
			(3209,'TiXsVnVlCEB6','E19','-10',0),
			(3210,'TiXsVnVlCEB6','H6','24',1),
			(3211,'TiXsVnVlCEB6','I1','-901',5),
			(3212,'TiXsVnVlCEB6','H14','0',0),
			(3213,'TiXsVnVlCEB6','B22','0',0),
			(3214,'TiXsVnVlCEB6','G3','0',0),
			(3215,'TiXsVnVlCEB6','I17','0',0),
			(3216,'TiXsVnVlCEB6','A11','-902',1),
			(3217,'TiXsVnVlCEB6','D16','0',0),
			(3218,'TiXsVnVlCEB6','J14','-10',0),
			(3219,'TiXsVnVlCEB6','E17','0',0),
			(3220,'TiXsVnVlCEB6','E11','59',0),
			(3221,'TiXsVnVlCEB6','K15','-104',3),
			(3222,'TiXsVnVlCEB6','H2','7',4),
			(3223,'TiXsVnVlCEB6','C13','0',0),
			(3224,'TiXsVnVlCEB6','J6','0',0),
			(3225,'TiXsVnVlCEB6','F10','58',1),
			(3226,'TiXsVnVlCEB6','B16','-10',0),
			(3227,'TiXsVnVlCEB6','E23','-11',5),
			(3228,'TiXsVnVlCEB6','F4','57',5),
			(3229,'TiXsVnVlCEB6','C9','0',0),
			(3230,'TiXsVnVlCEB6','D2','-5',0),
			(3231,'TiXsVnVlCEB6','I7','0',0),
			(3232,'TiXsVnVlCEB6','G17','-2',0),
			(3233,'TiXsVnVlCEB6','G9','0',0),
			(3234,'TiXsVnVlCEB6','I13','0',0),
			(3235,'TiXsVnVlCEB6','I19','-3',2),
			(3236,'TiXsVnVlCEB6','B20','-1',0),
			(3237,'TiXsVnVlCEB6','F22','-10',0),
			(3238,'TiXsVnVlCEB6','G5','26',0),
			(3239,'TiXsVnVlCEB6','I9','0',0),
			(3240,'TiXsVnVlCEB6','F14','0',0),
			(3241,'TiXsVnVlCEB6','I3','16',0),
			(3242,'TiXsVnVlCEB6','C7','0',0),
			(3243,'TiXsVnVlCEB6','D4','58',5),
			(3244,'TiXsVnVlCEB6','H10','57',1),
			(3245,'TiXsVnVlCEB6','F20','-2',0),
			(3246,'TiXsVnVlCEB6','F18','0',0),
			(3247,'TiXsVnVlCEB6','B12','0',0),
			(3248,'TiXsVnVlCEB6','D12','0',0),
			(3249,'TiXsVnVlCEB6','K13','-902',4),
			(3250,'TiXsVnVlCEB6','G15','0',0),
			(3251,'TiXsVnVlCEB6','F12','0',0),
			(3252,'TiXsVnVlCEB6','C23','0',0),
			(3253,'TiXsVnVlCEB6','E5','64',4),
			(3254,'TiXsVnVlCEB6','J4','0',0),
			(3255,'TiXsVnVlCEB6','A9','-901',1),
			(3256,'TiXsVnVlCEB6','C21','0',0)
		"
	);

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
		'error_callback' 	=> \&db_error,
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
	
	$holder->remove_private( 'p3' );
	ok( $holder->holds_private( 'p3' ) == 0 && $holder->holds_private( 'p2' ) == 1 , 'privates removed correctly' );
	
	my @test_list = sort( 'p1', 'p3' );
	my @current_list = sort( $holder->private_keys() );
	ok( @current_list ~~ @test_list, 'private keys returned correctly' );
	
	show( @current_list );
	
	ok( $holder->privates_text() eq 'p1,p3', 'private text returned correctly' );
	
	$holder->privates_from_text( 'a1', 'a3', 'a2' );
	ok( $holder->privates_text() eq 'a1,a2,a3', 'privates parsed from text' );
	
	
	
	
	
	
	return;
}


#############################################################################

sub test_Rails_Methods_Privates {
	my $connection		= shift;
	
	print "\nRails::Methods::Privates ... \n";
	
	use Rails::Methods::Privates;
	
	
	
	return;
}
	
exit();	
	

use Rails::Objects::Route;

print "\n";

my $route = Rails::Objects::Route->new();

$route->add_node( 'node1', 10 );
$route->add_node( 'node5', 50 );
$route->add_node( 'node3', 0 );
$route->add_node( 'node4', 0 );
$route->add_node( 'node2', 30 );

print "\n " . $route->as_text();


my $route2 = Rails::Objects::Route->new();

$route2->add_node( 'node5', 50 );
$route2->add_node( 'node6', 0 );
$route2->add_node( 'node7', 10 );
$route2->add_node( 'node8', 20 );

print "\n " . $route2->as_text();

if ( $route->contains_common_path( $route2 ) == 1 ) {
	print "\nCommon path found.";
}
else {
	print "\nNo Common path.";
}


my $route3 = Rails::Objects::Route->new();

$route3->add_node( 'node5', 50 );
$route3->add_node( 'node1', 10 );
$route3->add_node( 'node9', 10 );
$route3->add_node( 'node8', 0 );

print "\n " . $route3->as_text();

if ( $route->contains_common_path( $route3 ) == 1 ) {
	print "\nCommon path found.";
}
else {
	print "\nNo Common path.";
}











print "\n";
