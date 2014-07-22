package Rails::Methods::Database;

use strict;
use warnings;

use Exporter;

use Rails::Objects::Connection;

our @ISA	= qw( Exporter );
our @EXPORT = qw( 
	create_tables
	clear_tables
	delete_tables
);


my %_tables = (
	'corps' => 
		"CREATE TABLE `corps` ( 
			`id`         VARCHAR PRIMARY KEY NOT NULL,
			`name_long`  VARCHAR DEFAULT ( '' ),
			`name_short` VARCHAR DEFAULT ( '' ),
			`station`    VARCHAR DEFAULT ( '' ),
			`start_tile` VARCHAR DEFAULT ( '' ),
			`start_city` VARCHAR DEFAULT ( '' );
		INSERT INTO corps VALUES('prr','Pennsylvania','PRR','0,40,100,100','H12','city1');
		INSERT INTO corps VALUES('nyc','New York Central','NYC','0,40,100,100','E19','city1');
		INSERT INTO corps VALUES('cpr','Canadian Pacific','CPR','0,40,100,100','A19','city1');
		INSERT INTO corps VALUES('bo','Baltimore & Ohio','B&O','0,40,100','I15','city1');
		INSERT INTO corps VALUES('co','Chesapeake & Ohio','C&O','0,40,100','F6','city1');
		INSERT INTO corps VALUES('erie','Erie','ERIE','0,40,100','E11','city1');
		INSERT INTO corps VALUES('nnh','New York, New Haven & Hartford','NNH','0,40','G19','city1');
		INSERT INTO corps VALUES('bm','Boston & Maine','B&M','0,40','E23','city1');
		",
	'map_spaces' => 
		"CREATE TABLE `map_spaces` (
			`id` VARCHAR PRIMARY KEY  NOT NULL ,
			`tile_id` VARCHAR DEFAULT ('') ,
			`orientation` INTEGER DEFAULT (0) ,
			`minor` INTEGER DEFAULT (0) ,
			`major` INTEGER DEFAULT (0) ,
			`city` VARCHAR DEFAULT ('') ,
			`impassable` VARCHAR DEFAULT ('') ,
			`cost` INTEGER DEFAULT (0) ,
			`label` VARCHAR DEFAULT ('') ,
			`ob_city` VARCHAR);
		INSERT INTO map_spaces VALUES('I11','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('F16','-10',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('E15','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E13','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E21','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('J2','-902',5,30,60,'Gulf','',0,'','ob_gulfofmexico');
		INSERT INTO map_spaces VALUES('C11','0',0,0,0,'','D12',0,'','');
		INSERT INTO map_spaces VALUES('I5','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E9','-7',4,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G7','-2',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G19','-21',1,0,0,'New York','',80,'NY','');
		INSERT INTO map_spaces VALUES('D24','-7',2,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('D18','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E7','-1',0,0,0,'','F8',0,'','');
		INSERT INTO map_spaces VALUES('F8','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H18','-20',0,0,0,'','',0,'OO','');
		INSERT INTO map_spaces VALUES('H16','-10',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('A17','-7',1,0,0,'Montreal','',0,'','');
		INSERT INTO map_spaces VALUES('B18','0',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('C17','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('A19','-103',1,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H8','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B10','-10',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G11','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('J8','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B14','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('D6','0',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('D20','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('C19','0',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('D14','-102',0,20,20,'','',0,'','');
		INSERT INTO map_spaces VALUES('F2','-903',5,40,70,'Chicago','',0,'','ob_chicago');
		INSERT INTO map_spaces VALUES('D8','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H12','-101',0,0,0,'Altoona','',0,'','');
		INSERT INTO map_spaces VALUES('F24','-3',2,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E3','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B24','-902',2,20,30,'','',0,'','ob_maritimeprovinces');
		INSERT INTO map_spaces VALUES('I15','-11',0,0,0,'Baltimore','',0,'B','');
		INSERT INTO map_spaces VALUES('J12','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('D22','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('G13','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('H4','-10',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F6','-105',0,0,0,'Cleveland','',0,'','');
		INSERT INTO map_spaces VALUES('J10','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('E19','-10',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('C15','-58',2,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('D10','-20',0,0,0,'','',80,'OO','');
		INSERT INTO map_spaces VALUES('I1','-901',5,30,60,'Gulf','',0,'','ob_gulfofmexico');
		INSERT INTO map_spaces VALUES('H6','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H14','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B22','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G3','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('I17','0',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('A11','-902',1,30,50,'Canadian West','',0,'','ob_canadianwest');
		INSERT INTO map_spaces VALUES('D16','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('J14','-10',0,0,0,'Washington','',80,'','');
		INSERT INTO map_spaces VALUES('E17','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('E11','-20',0,0,0,'','',0,'OO','');
		INSERT INTO map_spaces VALUES('K15','-104',3,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H2','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('C13','0',0,0,0,'','D12',0,'','');
		INSERT INTO map_spaces VALUES('J6','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F10','-1',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B16','-10',0,0,0,'','C17',0,'','');
		INSERT INTO map_spaces VALUES('E23','-11',5,0,0,'Boston','',0,'B','');
		INSERT INTO map_spaces VALUES('C9','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F4','-10',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('D2','-5',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('I7','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G17','-2',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G9','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('I13','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('I19','-3',2,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B20','-1',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F22','-10',0,0,0,'','',80,'','');
		INSERT INTO map_spaces VALUES('I9','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G5','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('I3','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F14','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('C7','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('D4','-1',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('H10','-10',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('B12','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F18','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F20','-2',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('K13','-902',4,30,40,'Deep South','',0,'','ob_deepsouth');
		INSERT INTO map_spaces VALUES('D12','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('C23','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('F12','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('G15','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('J4','0',0,0,0,'','',0,'','');
		INSERT INTO map_spaces VALUES('E5','-20',0,0,0,'','',80,'OO','');
		INSERT INTO map_spaces VALUES('C21','0',0,0,0,'','',120,'','');
		INSERT INTO map_spaces VALUES('A9','-901',1,30,50,'Canadian West','',0,'','ob_canadianwest');
		",
		
	'state_auction' => 
		"CREATE TABLE `state_auction` ( 
			id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			private_id VARCHAR DEFAULT ( '' ),
			player_id  INTEGER DEFAULT ( 0 ),
			bid        INTEGER DEFAULT ( 0 ),
			waiting_on INTEGER DEFAULT ( 0 ),
			game_id    VARCHAR DEFAULT ( '' )
		)",
		
	'state_change_stamps' => 
		"CREATE TABLE `state_change_stamps` (
			`id` INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
			`game_id` VARCHAR NOT NULL , 
			`stamp_name` VARCHAR NOT NULL , 
			`stamp_value` INTEGER
		)",
		
	'state_corps' =>
			
		"CREATE TABLE state_corps ( 
			`id`               INTEGER PRIMARY KEY NOT NULL,
			`game_id`          INTEGER DEFAULT ( 0 ),
			`corp_id`          VARCHAR DEFAULT ( '' ),
			`cash`             INTEGER DEFAULT ( 0 ),
			`trains`           VARCHAR DEFAULT ( '' ),
			`privates`         VARCHAR DEFAULT ( '' ),
			`stations`         VARCHAR DEFAULT ( '' ),
			`shares`           VARCHAR DEFAULT ( '' ),
			`par_price`        INTEGER DEFAULT ( 0 ),
			`current_price`    INTEGER DEFAULT ( 0 ),
			`current_index`    INTEGER DEFAULT ( 0 ),
			`current_position` VARCHAR DEFAULT ( '' )
		)",
		
	'state_game' =>
		"CREATE TABLE `state_game` (
			`id` VARCHAR PRIMARY KEY  NOT NULL ,
			`cash` INTEGER DEFAULT (0) ,
			`shares` VARCHAR DEFAULT ('') ,
			`privates` VARCHAR DEFAULT ('') ,
			`trains` VARCHAR DEFAULT ('') ,
			`current_phase` INTEGER DEFAULT (0) ,
			`next_phase` INTEGER DEFAULT (0) ,
			`current_round` INTEGER DEFAULT (0) ,
			`current_player` INTEGER DEFAULT (0) ,
			`game_name` VARCHAR DEFAULT ('') ,
			`prioritydeal_player` INTEGER DEFAULT (0) ,
			`player_count` INTEGER DEFAULT (0) ,
			`depreciate_private` INTEGER DEFAULT (0) ,
			`auction_players` VARCHAR DEFAULT ('') ,
			`corp_turns` VARCHAR,
			`new_trains` VARCHAR
		)",
		
	'state_players' =>
		"CREATE TABLE `state_players` (
			`id`		INTEGER PRIMARY KEY NOT NULL,
			`game_id` 	VARCHAR DEFAULT ( '' ),
			`player_id`	INTEGER DEFAULT ( 0 ),
			`long_name`	VARCHAR DEFAULT ( '' ),
			`cash` 		INTEGER DEFAULT ( 0 ),
			`shares` 	VARCHAR DEFAULT ( '' ),
			`privates` 	VARCHAR DEFAULT ( '' ),
			`running` 	VARCHAR DEFAULT ( '' ),
			`pass_flag` INTEGER DEFAULT ( 0 ),
			`sold` 		VARCHAR DEFAULT ( '' ), 
			`bought` 	VARCHAR DEFAULT ( '' )
		)",
		
	'state_stations' =>
		"CREATE TABLE `state_stations` (
			`id` INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
			`game_id` VARCHAR NOT NULL , 
			`space_id` VARCHAR NOT NULL , 
			`station_id` VARCHAR NOT NULL , 
			`slot_id` INTEGER NOT NULL  DEFAULT 0, 
			`corp` VARCHAR NOT NULL 
		)",
		
	'state_tile_locations' =>
		"CREATE TABLE `state_tile_locations` ( 
			`id`          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			`game_id`     INTEGER DEFAULT ( '' ),
			`space_id`    VARCHAR DEFAULT ( '' ),
			`tile_id`     VARCHAR DEFAULT ( '' ),
			`orientation` INTEGER DEFAULT ( 0 )
		)",
		
	'stations' => 
		"CREATE TABLE `stations` ( 
			`id`         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			`tile_id`    VARCHAR DEFAULT ( '' ),
			`station_id` VARCHAR DEFAULT ( '' ),
			`type`       VARCHAR DEFAULT ( '' ),
			`location`   VARCHAR DEFAULT ( '' ),
			`slots`      INTEGER DEFAULT ( 0 ),
			`revenue`    INTEGER DEFAULT ( 0 ),
			`ignorable`  INTEGER DEFAULT ( 0 )
		);
		INSERT INTO stations VALUES(2,'63','city1','City','0',2,40,0);
		INSERT INTO stations VALUES(3,'-902','city1','OffMapCity','0',0,-1,0);
		INSERT INTO stations VALUES(4,'55','city2','Town','302',1,10,0);
		INSERT INTO stations VALUES(5,'55','city1','Town','202',1,10,0);
		INSERT INTO stations VALUES(6,'-903','city1','OffMapCity','0',0,-1,0);
		INSERT INTO stations VALUES(7,'-3','city1','Town','252',0,10,0);
		INSERT INTO stations VALUES(8,'57','city1','City','0',1,20,0);
		INSERT INTO stations VALUES(9,'61','city1','City','0',1,60,0);
		INSERT INTO stations VALUES(10,'-104','city1','City','0',1,20,0);
		INSERT INTO stations VALUES(11,'-105','city1','City','0',1,30,0);
		INSERT INTO stations VALUES(12,'-20','city2','City','302',1,0,0);
		INSERT INTO stations VALUES(13,'-20','city1','City','2',1,0,0);
		INSERT INTO stations VALUES(14,'-58','city1','Town','301',0,10,0);
		INSERT INTO stations VALUES(15,'65','city2','City','252',1,50,0);
		INSERT INTO stations VALUES(16,'65','city1','City','501',1,50,0);
		INSERT INTO stations VALUES(17,'64','city2','City','52',1,50,0);
		INSERT INTO stations VALUES(18,'64','city1','City','401',1,50,0);
		INSERT INTO stations VALUES(19,'58','city1','Town','401',0,10,0);
		INSERT INTO stations VALUES(20,'15','city1','City','0',2,30,0);
		INSERT INTO stations VALUES(21,'-10','city1','City','302',0,0,0);
		INSERT INTO stations VALUES(22,'56','city2','Town','108',1,10,0);
		INSERT INTO stations VALUES(23,'56','city1','Town','407',1,10,0);
		INSERT INTO stations VALUES(24,'66','city2','City','452',1,50,0);
		INSERT INTO stations VALUES(25,'66','city1','City','2',1,50,0);
		INSERT INTO stations VALUES(26,'-2','city2','Town','302',0,0,0);
		INSERT INTO stations VALUES(27,'-2','city1','Town','102',0,0,0);
		INSERT INTO stations VALUES(28,'62','city2','City','2',2,80,0);
		INSERT INTO stations VALUES(29,'62','city1','City','302',2,80,0);
		INSERT INTO stations VALUES(30,'-11','city1','City','0',1,30,0);
		INSERT INTO stations VALUES(31,'54','city2','City','552',1,60,0);
		INSERT INTO stations VALUES(32,'54','city1','City','352',1,60,0);
		INSERT INTO stations VALUES(33,'67','city2','City','502',1,50,0);
		INSERT INTO stations VALUES(34,'67','city1','City','307',1,50,0);
		INSERT INTO stations VALUES(35,'-901','city1','OffMapCity','0',0,-1,0);
		INSERT INTO stations VALUES(36,'68','city2','City','502',1,50,0);
		INSERT INTO stations VALUES(37,'68','city1','City','302',1,50,0);
		INSERT INTO stations VALUES(38,'2','city1','Town','109',0,10,0);
		INSERT INTO stations VALUES(39,'1','city1','Town','108',0,10,0);
		INSERT INTO stations VALUES(40,'14','city1','City','0',2,30,0);
		INSERT INTO stations VALUES(41,'69','city2','Town','2',1,10,0);
		INSERT INTO stations VALUES(42,'69','city1','Town','407',1,10,0);
		INSERT INTO stations VALUES(43,'59','city2','City','352',1,40,0);
		INSERT INTO stations VALUES(44,'59','city1','City','52',1,40,0);
		INSERT INTO stations VALUES(45,'-21','city2','City','502',1,40,0);
		INSERT INTO stations VALUES(46,'-21','city1','City','202',1,40,0);
		INSERT INTO stations VALUES(47,'-103','city1','City','0',1,40,0);
		INSERT INTO stations VALUES(48,'-101','city1','City','0',1,10,1);
		INSERT INTO stations VALUES(49,'53','city1','City','0',1,50,0);
		INSERT INTO stations VALUES(50,'-102','city1','City','251',1,20,0);
		INSERT INTO stations VALUES(51,'-5','city1','City','0',1,20,0);
		INSERT INTO stations VALUES(52,'3','city1','Town','352',0,10,0);
		INSERT INTO stations VALUES(53,'4','city1','Town','0',0,10,0);
		INSERT INTO stations VALUES(54,'-1','city1','Town','2',0,0,0);
		",
		
	'tile_upgrades' =>
		"CREATE TABLE `tile_upgrades` ( 
			`id`          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			`tile_id`     VARCHAR DEFAULT ( '' ),
			`new_tile_id` VARCHAR DEFAULT ( '' ) 
		);
		INSERT INTO tile_upgrades VALUES(1,'7','18');
		INSERT INTO tile_upgrades VALUES(2,'7','26');
		INSERT INTO tile_upgrades VALUES(3,'7','27');
		INSERT INTO tile_upgrades VALUES(4,'7','28');
		INSERT INTO tile_upgrades VALUES(5,'7','29');
		INSERT INTO tile_upgrades VALUES(6,'26','42');
		INSERT INTO tile_upgrades VALUES(7,'26','44');
		INSERT INTO tile_upgrades VALUES(8,'26','45');
		INSERT INTO tile_upgrades VALUES(9,'18','43');
		INSERT INTO tile_upgrades VALUES(10,'16','43');
		INSERT INTO tile_upgrades VALUES(11,'16','70');
		INSERT INTO tile_upgrades VALUES(12,'27','41');
		INSERT INTO tile_upgrades VALUES(13,'27','44');
		INSERT INTO tile_upgrades VALUES(14,'27','46');
		INSERT INTO tile_upgrades VALUES(15,'57','14');
		INSERT INTO tile_upgrades VALUES(16,'57','15');
		INSERT INTO tile_upgrades VALUES(17,'20','44');
		INSERT INTO tile_upgrades VALUES(18,'20','47');
		INSERT INTO tile_upgrades VALUES(19,'-20','59');
		INSERT INTO tile_upgrades VALUES(20,'29','39');
		INSERT INTO tile_upgrades VALUES(21,'29','45');
		INSERT INTO tile_upgrades VALUES(22,'29','70');
		INSERT INTO tile_upgrades VALUES(23,'15','63');
		INSERT INTO tile_upgrades VALUES(24,'19','45');
		INSERT INTO tile_upgrades VALUES(25,'19','46');
		INSERT INTO tile_upgrades VALUES(26,'-11','53');
		INSERT INTO tile_upgrades VALUES(27,'54','62');
		INSERT INTO tile_upgrades VALUES(28,'25','40');
		INSERT INTO tile_upgrades VALUES(29,'25','45');
		INSERT INTO tile_upgrades VALUES(30,'25','46');
		INSERT INTO tile_upgrades VALUES(31,'28','39');
		INSERT INTO tile_upgrades VALUES(32,'28','46');
		INSERT INTO tile_upgrades VALUES(33,'28','70');
		INSERT INTO tile_upgrades VALUES(34,'14','63');
		INSERT INTO tile_upgrades VALUES(35,'59','64');
		INSERT INTO tile_upgrades VALUES(36,'59','65');
		INSERT INTO tile_upgrades VALUES(37,'59','66');
		INSERT INTO tile_upgrades VALUES(38,'59','67');
		INSERT INTO tile_upgrades VALUES(39,'59','68');
		INSERT INTO tile_upgrades VALUES(40,'-21','54');
		INSERT INTO tile_upgrades VALUES(41,'24','42');
		INSERT INTO tile_upgrades VALUES(42,'24','43');
		INSERT INTO tile_upgrades VALUES(43,'24','46');
		INSERT INTO tile_upgrades VALUES(44,'24','47');
		INSERT INTO tile_upgrades VALUES(45,'53','61');
		INSERT INTO tile_upgrades VALUES(46,'23','41');
		INSERT INTO tile_upgrades VALUES(47,'23','43');
		INSERT INTO tile_upgrades VALUES(48,'23','45');
		INSERT INTO tile_upgrades VALUES(49,'23','47');
		INSERT INTO tile_upgrades VALUES(50,'9','18');
		INSERT INTO tile_upgrades VALUES(51,'9','19');
		INSERT INTO tile_upgrades VALUES(52,'9','20');
		INSERT INTO tile_upgrades VALUES(53,'9','23');
		INSERT INTO tile_upgrades VALUES(54,'9','24');
		INSERT INTO tile_upgrades VALUES(55,'9','26');
		INSERT INTO tile_upgrades VALUES(56,'9','27');
		INSERT INTO tile_upgrades VALUES(57,'8','16');
		INSERT INTO tile_upgrades VALUES(58,'8','19');
		INSERT INTO tile_upgrades VALUES(59,'8','23');
		INSERT INTO tile_upgrades VALUES(60,'8','24');
		INSERT INTO tile_upgrades VALUES(61,'8','25');
		INSERT INTO tile_upgrades VALUES(62,'8','28');
		INSERT INTO tile_upgrades VALUES(63,'8','29');
		",
		
	'tiles' =>
		"CREATE TABLE tiles ( 
			`tile_id`   VARCHAR PRIMARY KEY NOT NULL,
			`color`     VARCHAR DEFAULT ( '' ),
			`title`     VARCHAR DEFAULT ( '' ),
			`mix_count` INTEGER DEFAULT ( 0 ) 
		);
		INSERT INTO tiles VALUES('63','brown','63',3);
		INSERT INTO tiles VALUES('7','yellow','7',4);
		INSERT INTO tiles VALUES('26','green','26',1);
		INSERT INTO tiles VALUES('-902','red','OM 2 way',-1);
		INSERT INTO tiles VALUES('18','green','18',1);
		INSERT INTO tiles VALUES('16','green','16',1);
		INSERT INTO tiles VALUES('44','brown','44',1);
		INSERT INTO tiles VALUES('55','yellow','55',1);
		INSERT INTO tiles VALUES('-903','red','OM 3 way',-1);
		INSERT INTO tiles VALUES('-3','fixed','MF 3',-1);
		INSERT INTO tiles VALUES('27','green','27',1);
		INSERT INTO tiles VALUES('57','yellow','57',4);
		INSERT INTO tiles VALUES('61','brown','61',2);
		INSERT INTO tiles VALUES('-104','fixed','MF 104',-1);
		INSERT INTO tiles VALUES('20','green','20',1);
		INSERT INTO tiles VALUES('-105','fixed','MF 105',-1);
		INSERT INTO tiles VALUES('-20','yellow','2 cities',-1);
		INSERT INTO tiles VALUES('-7','fixed','MF 7',-1);
		INSERT INTO tiles VALUES('-58','fixed','MF 58',-1);
		INSERT INTO tiles VALUES('65','brown','65',1);
		INSERT INTO tiles VALUES('29','green','29',1);
		INSERT INTO tiles VALUES('39','brown','39',1);
		INSERT INTO tiles VALUES('64','brown','64',1);
		INSERT INTO tiles VALUES('41','brown','41',2);
		INSERT INTO tiles VALUES('58','yellow','58',2);
		INSERT INTO tiles VALUES('15','green','15',2);
		INSERT INTO tiles VALUES('-10','white','1 city',-1);
		INSERT INTO tiles VALUES('56','yellow','56',1);
		INSERT INTO tiles VALUES('66','brown','66',1);
		INSERT INTO tiles VALUES('45','brown','45',2);
		INSERT INTO tiles VALUES('-2','white','2 villages',-1);
		INSERT INTO tiles VALUES('19','green','19',1);
		INSERT INTO tiles VALUES('62','brown','62',1);
		INSERT INTO tiles VALUES('-11','yellow','B',-1);
		INSERT INTO tiles VALUES('54','green','54',1);
		INSERT INTO tiles VALUES('67','brown','67',1);
		INSERT INTO tiles VALUES('70','brown','70',1);
		INSERT INTO tiles VALUES('-901','red','OM 1 way',-1);
		INSERT INTO tiles VALUES('68','brown','68',1);
		INSERT INTO tiles VALUES('2','yellow','2',1);
		INSERT INTO tiles VALUES('1','yellow','1',1);
		INSERT INTO tiles VALUES('25','green','25',1);
		INSERT INTO tiles VALUES('28','green','28',1);
		INSERT INTO tiles VALUES('40','brown','40',1);
		INSERT INTO tiles VALUES('14','green','14',3);
		INSERT INTO tiles VALUES('69','yellow','69',1);
		INSERT INTO tiles VALUES('59','green','59',2);
		INSERT INTO tiles VALUES('-21','yellow','NY',-1);
		INSERT INTO tiles VALUES('24','green','24',3);
		INSERT INTO tiles VALUES('-103','fixed','MF 103',-1);
		INSERT INTO tiles VALUES('-101','fixed','Philadelphia',-1);
		INSERT INTO tiles VALUES('53','green','53',2);
		INSERT INTO tiles VALUES('42','brown','42',2);
		INSERT INTO tiles VALUES('-102','fixed','-102',-1);
		INSERT INTO tiles VALUES('0','white','empty',-1);
		INSERT INTO tiles VALUES('46','brown','46',2);
		INSERT INTO tiles VALUES('23','green','23',3);
		INSERT INTO tiles VALUES('-5','fixed','MF 5',-1);
		INSERT INTO tiles VALUES('3','yellow','3',2);
		INSERT INTO tiles VALUES('9','yellow','9',7);
		INSERT INTO tiles VALUES('47','brown','47',1);
		INSERT INTO tiles VALUES('8','yellow','8',8);
		INSERT INTO tiles VALUES('4','yellow','4',2);
		INSERT INTO tiles VALUES('43','brown','43',2);
		INSERT INTO tiles VALUES('-1','white','1 village',-1);
		",
		
	'tracks' =>	
		"CREATE TABLE `tracks` ( 
			`id`      		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			`tile_id` 		VARCHAR DEFAULT ( '' ),
			`start_point`	VARCHAR DEFAULT ( '' ),
			`end_point`		VARCHAR DEFAULT ( '' )
		);
		INSERT INTO tracks VALUES(7,'63','city1','side0');
		INSERT INTO tracks VALUES(8,'63','city1','side1');
		INSERT INTO tracks VALUES(9,'63','city1','side2');
		INSERT INTO tracks VALUES(10,'63','city1','side3');
		INSERT INTO tracks VALUES(11,'63','city1','side4');
		INSERT INTO tracks VALUES(12,'63','city1','side5');
		INSERT INTO tracks VALUES(13,'7','side3','side4');
		INSERT INTO tracks VALUES(14,'26','side0','side3');
		INSERT INTO tracks VALUES(15,'26','side0','side5');
		INSERT INTO tracks VALUES(16,'-902','city1','side2');
		INSERT INTO tracks VALUES(17,'-902','city1','side1');
		INSERT INTO tracks VALUES(18,'18','side0','side3');
		INSERT INTO tracks VALUES(19,'18','side4','side5');
		INSERT INTO tracks VALUES(20,'16','side0','side4');
		INSERT INTO tracks VALUES(21,'16','side5','side3');
		INSERT INTO tracks VALUES(22,'44','side0','side3');
		INSERT INTO tracks VALUES(23,'44','side0','side1');
		INSERT INTO tracks VALUES(24,'44','side4','side3');
		INSERT INTO tracks VALUES(25,'44','side4','side1');
		INSERT INTO tracks VALUES(26,'55','city1','side2');
		INSERT INTO tracks VALUES(27,'55','city1','side5');
		INSERT INTO tracks VALUES(28,'55','city2','side3');
		INSERT INTO tracks VALUES(29,'55','city2','side0');
		INSERT INTO tracks VALUES(30,'-903','city1','side3');
		INSERT INTO tracks VALUES(31,'-903','city1','side2');
		INSERT INTO tracks VALUES(32,'-903','city1','side1');
		INSERT INTO tracks VALUES(33,'-3','city1','side2');
		INSERT INTO tracks VALUES(34,'-3','city1','side3');
		INSERT INTO tracks VALUES(35,'27','side0','side3');
		INSERT INTO tracks VALUES(36,'27','side4','side3');
		INSERT INTO tracks VALUES(37,'57','city1','side3');
		INSERT INTO tracks VALUES(38,'57','city1','side0');
		INSERT INTO tracks VALUES(39,'61','city1','side0');
		INSERT INTO tracks VALUES(40,'61','city1','side1');
		INSERT INTO tracks VALUES(41,'61','city1','side3');
		INSERT INTO tracks VALUES(42,'61','city1','side5');
		INSERT INTO tracks VALUES(43,'-104','city1','side2');
		INSERT INTO tracks VALUES(44,'20','side0','side3');
		INSERT INTO tracks VALUES(45,'20','side1','side4');
		INSERT INTO tracks VALUES(46,'-105','city1','side2');
		INSERT INTO tracks VALUES(47,'-105','city1','side3');
		INSERT INTO tracks VALUES(48,'-7','side1','side2');
		INSERT INTO tracks VALUES(49,'-58','city1','side2');
		INSERT INTO tracks VALUES(50,'-58','city1','side4');
		INSERT INTO tracks VALUES(51,'65','city1','side4');
		INSERT INTO tracks VALUES(52,'65','city1','side0');
		INSERT INTO tracks VALUES(53,'65','city2','side2');
		INSERT INTO tracks VALUES(54,'65','city2','side3');
		INSERT INTO tracks VALUES(55,'29','side5','side3');
		INSERT INTO tracks VALUES(56,'29','side4','side3');
		INSERT INTO tracks VALUES(57,'39','side3','side4');
		INSERT INTO tracks VALUES(58,'39','side5','side3');
		INSERT INTO tracks VALUES(59,'39','side4','side5');
		INSERT INTO tracks VALUES(60,'64','city1','side3');
		INSERT INTO tracks VALUES(61,'64','city1','side5');
		INSERT INTO tracks VALUES(62,'64','city2','side1');
		INSERT INTO tracks VALUES(63,'64','city2','side0');
		INSERT INTO tracks VALUES(64,'41','side3','side0');
		INSERT INTO tracks VALUES(65,'41','side4','side3');
		INSERT INTO tracks VALUES(66,'41','side0','side4');
		INSERT INTO tracks VALUES(67,'58','city1','side5');
		INSERT INTO tracks VALUES(68,'58','city1','side3');
		INSERT INTO tracks VALUES(69,'15','city1','side0');
		INSERT INTO tracks VALUES(70,'15','city1','side4');
		INSERT INTO tracks VALUES(71,'15','city1','side5');
		INSERT INTO tracks VALUES(72,'15','city1','side3');
		INSERT INTO tracks VALUES(73,'56','city1','side2');
		INSERT INTO tracks VALUES(74,'56','city1','side4');
		INSERT INTO tracks VALUES(75,'56','city2','side3');
		INSERT INTO tracks VALUES(76,'56','city2','side1');
		INSERT INTO tracks VALUES(77,'66','city1','side3');
		INSERT INTO tracks VALUES(78,'66','city1','side0');
		INSERT INTO tracks VALUES(79,'66','city2','side4');
		INSERT INTO tracks VALUES(80,'66','city2','side5');
		INSERT INTO tracks VALUES(81,'45','side0','side3');
		INSERT INTO tracks VALUES(82,'45','side0','side5');
		INSERT INTO tracks VALUES(83,'45','side1','side5');
		INSERT INTO tracks VALUES(84,'45','side3','side1');
		INSERT INTO tracks VALUES(85,'19','side0','side3');
		INSERT INTO tracks VALUES(86,'19','side1','side5');
		INSERT INTO tracks VALUES(87,'62','city1','side3');
		INSERT INTO tracks VALUES(88,'62','city1','side4');
		INSERT INTO tracks VALUES(89,'62','city2','side5');
		INSERT INTO tracks VALUES(90,'62','city2','side0');
		INSERT INTO tracks VALUES(91,'-11','city1','side1');
		INSERT INTO tracks VALUES(92,'-11','city1','side3');
		INSERT INTO tracks VALUES(93,'54','city1','side3');
		INSERT INTO tracks VALUES(94,'54','city1','side4');
		INSERT INTO tracks VALUES(95,'54','city2','side5');
		INSERT INTO tracks VALUES(96,'54','city2','side0');
		INSERT INTO tracks VALUES(97,'67','city1','side1');
		INSERT INTO tracks VALUES(98,'67','city1','side3');
		INSERT INTO tracks VALUES(99,'67','city2','side5');
		INSERT INTO tracks VALUES(100,'67','city2','side2');
		INSERT INTO tracks VALUES(101,'70','side0','side4');
		INSERT INTO tracks VALUES(102,'70','side0','side5');
		INSERT INTO tracks VALUES(103,'70','side4','side3');
		INSERT INTO tracks VALUES(104,'70','side5','side3');
		INSERT INTO tracks VALUES(105,'-901','city1','side2');
		INSERT INTO tracks VALUES(106,'68','city1','side3');
		INSERT INTO tracks VALUES(107,'68','city1','side0');
		INSERT INTO tracks VALUES(108,'68','city2','side2');
		INSERT INTO tracks VALUES(109,'68','city2','side5');
		INSERT INTO tracks VALUES(110,'2','city1','side0');
		INSERT INTO tracks VALUES(111,'2','city1','side3');
		INSERT INTO tracks VALUES(112,'2','city2','side1');
		INSERT INTO tracks VALUES(113,'2','city2','side2');
		INSERT INTO tracks VALUES(114,'1','city1','side0');
		INSERT INTO tracks VALUES(115,'1','city1','side4');
		INSERT INTO tracks VALUES(116,'1','city2','side1');
		INSERT INTO tracks VALUES(117,'1','city2','side3');
		INSERT INTO tracks VALUES(118,'25','side1','side3');
		INSERT INTO tracks VALUES(119,'25','side5','side3');
		INSERT INTO tracks VALUES(120,'28','side5','side3');
		INSERT INTO tracks VALUES(121,'28','side5','side4');
		INSERT INTO tracks VALUES(122,'40','side1','side3');
		INSERT INTO tracks VALUES(123,'40','side1','side5');
		INSERT INTO tracks VALUES(124,'40','side5','side3');
		INSERT INTO tracks VALUES(125,'14','city1','side0');
		INSERT INTO tracks VALUES(126,'14','city1','side1');
		INSERT INTO tracks VALUES(127,'14','city1','side3');
		INSERT INTO tracks VALUES(128,'14','city1','side4');
		INSERT INTO tracks VALUES(129,'69','city1','side2');
		INSERT INTO tracks VALUES(130,'69','city1','side4');
		INSERT INTO tracks VALUES(131,'69','city2','side3');
		INSERT INTO tracks VALUES(132,'69','city2','side0');
		INSERT INTO tracks VALUES(133,'59','city1','side1');
		INSERT INTO tracks VALUES(134,'59','city2','side3');
		INSERT INTO tracks VALUES(135,'-21','city1','side2');
		INSERT INTO tracks VALUES(136,'-21','city2','side5');
		INSERT INTO tracks VALUES(137,'24','side0','side3');
		INSERT INTO tracks VALUES(138,'24','side5','side3');
		INSERT INTO tracks VALUES(139,'-103','city1','side2');
		INSERT INTO tracks VALUES(140,'-103','city1','side3');
		INSERT INTO tracks VALUES(141,'-101','city1','side1');
		INSERT INTO tracks VALUES(142,'-101','city1','side4');
		INSERT INTO tracks VALUES(143,'-101','side4','side1');
		INSERT INTO tracks VALUES(144,'53','city1','side1');
		INSERT INTO tracks VALUES(145,'53','city1','side3');
		INSERT INTO tracks VALUES(146,'53','city1','side5');
		INSERT INTO tracks VALUES(147,'42','side5','side0');
		INSERT INTO tracks VALUES(148,'42','side5','side3');
		INSERT INTO tracks VALUES(149,'42','side0','side3');
		INSERT INTO tracks VALUES(150,'-102','city1','side1');
		INSERT INTO tracks VALUES(151,'-102','city1','side3');
		INSERT INTO tracks VALUES(152,'-102','city1','side4');
		INSERT INTO tracks VALUES(153,'46','side0','side3');
		INSERT INTO tracks VALUES(154,'46','side1','side0');
		INSERT INTO tracks VALUES(155,'46','side3','side5');
		INSERT INTO tracks VALUES(156,'46','side1','side5');
		INSERT INTO tracks VALUES(157,'23','side0','side3');
		INSERT INTO tracks VALUES(158,'23','side0','side4');
		INSERT INTO tracks VALUES(159,'-5','city1','side2');
		INSERT INTO tracks VALUES(160,'-5','city1','side1');
		INSERT INTO tracks VALUES(161,'3','city1','side3');
		INSERT INTO tracks VALUES(162,'3','city1','side4');
		INSERT INTO tracks VALUES(163,'9','side3','side0');
		INSERT INTO tracks VALUES(164,'47','side0','side4');
		INSERT INTO tracks VALUES(165,'47','side0','side3');
		INSERT INTO tracks VALUES(166,'47','side1','side4');
		INSERT INTO tracks VALUES(167,'47','side3','side1');
		INSERT INTO tracks VALUES(168,'8','side3','side5');
		INSERT INTO tracks VALUES(169,'4','city1','side3');
		INSERT INTO tracks VALUES(170,'4','city1','side0');
		INSERT INTO tracks VALUES(171,'43','side0','side3');
		INSERT INTO tracks VALUES(172,'43','side0','side4');
		INSERT INTO tracks VALUES(173,'43','side5','side3');
		INSERT INTO tracks VALUES(174,'43','side5','side4');
		",			
);

#############################################################################

sub create_tables {
	my $connection		= shift;
	
	foreach my $table_name ( sort( keys( %_tables ) ) ) {
		$connection->simple_exec( $_tables{ $table_name } );
	}
	
	return;	
}

#############################################################################

sub clear_tables {
	my $connection		= shift;
	
	foreach my $table_name ( keys( %_tables ) ) {
		$connection->simple_exec( 'DELETE FROM ' . $table_name . '; VACUUM;' );
	}
	
	return;
}
		
#############################################################################

sub delete_tables {
	my $connection		= shift;
	
	foreach my $table_name ( keys( %_tables ) ) {
		$connection->simple_exec( 'DROP TABLE ' . $table_name . '; VACUUM;' );
	}
	
	return;
}		

#############################################################################
#############################################################################
1