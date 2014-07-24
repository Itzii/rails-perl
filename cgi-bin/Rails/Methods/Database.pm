package Rails::Methods::Database;

use strict;
use warnings;

use Exporter;

use Base::Objects::Connection;

our @ISA	= qw( Exporter );
our @EXPORT = qw( 
	create_tables
	clear_tables
	delete_tables
);


my %_tables = (
	'corps' => {
		'count' => 8,
		'sql' =>
			"CREATE TABLE `corps` ( 
				`id`         VARCHAR PRIMARY KEY NOT NULL,
				`name_long`  VARCHAR DEFAULT ( '' ),
				`name_short` VARCHAR DEFAULT ( '' ),
				`station`    VARCHAR DEFAULT ( '' ),
				`start_tile` VARCHAR DEFAULT ( '' ),
				`start_city` VARCHAR DEFAULT ( '' ) 
			)",
		'data' =>
			"INSERT INTO corps (id,name_long,name_short,station,start_tile,start_city) VALUES
			('prr','Pennsylvania','PRR','0,40,100,100','H12','city1'),
			('nyc','New York Central','NYC','0,40,100,100','E19','city1'),
			('cpr','Canadian Pacific','CPR','0,40,100,100','A19','city1'),
			('bo','Baltimore & Ohio','B&O','0,40,100','I15','city1'),
			('co','Chesapeake & Ohio','C&O','0,40,100','F6','city1'),
			('erie','Erie','ERIE','0,40,100','E11','city1'),
			('nnh','New York, New Haven & Hartford','NNH','0,40','G19','city1'),
			('bm','Boston & Maine','B&M','0,40','E23','city1')
			",
	},
		
	'map_spaces' => {
		'count' => 93,
		'sql' =>
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
				`ob_city` VARCHAR 
			)",
		'data' =>
			"INSERT INTO map_spaces (id,tile_id,orientation,minor,major,city,impassable,cost,label,ob_city) VALUES
			('A11','-902',1,30,50,'Canadian West','',0,'','ob_canadianwest'),
			('A17','-7',1,0,0,'Montreal','',0,'',''),
			('A19','-103',1,0,0,'','',0,'',''),
			('A9','-901',1,30,50,'Canadian West','',0,'','ob_canadianwest'),
			('B10','-10',0,0,0,'','',0,'',''),
			('B12','0',0,0,0,'','',0,'',''),
			('B14','0',0,0,0,'','',0,'',''),
			('B16','-10',0,0,0,'','C17',0,'',''),
			('B18','0',0,0,0,'','',80,'',''),
			('B20','-1',0,0,0,'','',0,'',''),
			('B22','0',0,0,0,'','',0,'',''),
			('B24','-902',2,20,30,'','',0,'','ob_maritimeprovinces'),
			('C11','0',0,0,0,'','D12',0,'',''),
			('C13','0',0,0,0,'','D12',0,'',''),
			('C15','-58',2,0,0,'','',0,'',''),
			('C17','0',0,0,0,'','',120,'',''),
			('C19','0',0,0,0,'','',80,'',''),
			('C21','0',0,0,0,'','',120,'',''),
			('C23','0',0,0,0,'','',0,'',''),
			('C7','0',0,0,0,'','',0,'',''),
			('C9','0',0,0,0,'','',0,'',''),
			('D10','-20',0,0,0,'','',80,'OO',''),
			('D12','0',0,0,0,'','',0,'',''),
			('D14','-102',0,20,20,'','',0,'',''),
			('D16','0',0,0,0,'','',0,'',''),
			('D18','0',0,0,0,'','',0,'',''),
			('D2','-5',0,0,0,'','',0,'',''),
			('D20','0',0,0,0,'','',0,'',''),
			('D22','0',0,0,0,'','',120,'',''),
			('D24','-7',2,0,0,'','',0,'',''),
			('D4','-1',0,0,0,'','',0,'',''),
			('D6','0',0,0,0,'','',80,'',''),
			('D8','0',0,0,0,'','',0,'',''),
			('E11','-20',0,0,0,'','',0,'OO',''),
			('E13','0',0,0,0,'','',0,'',''),
			('E15','0',0,0,0,'','',0,'',''),
			('E17','0',0,0,0,'','',120,'',''),
			('E19','-10',0,0,0,'','',0,'',''),
			('E21','0',0,0,0,'','',120,'',''),
			('E23','-11',5,0,0,'Boston','',0,'B',''),
			('E3','0',0,0,0,'','',0,'',''),
			('E5','-20',0,0,0,'','',80,'OO',''),
			('E7','-1',0,0,0,'','F8',0,'',''),
			('E9','-7',4,0,0,'','',0,'',''),
			('F10','-1',0,0,0,'','',0,'',''),
			('F12','0',0,0,0,'','',0,'',''),
			('F14','0',0,0,0,'','',0,'',''),
			('F16','-10',0,0,0,'','',120,'',''),
			('F18','0',0,0,0,'','',0,'',''),
			('F2','-903',5,40,70,'Chicago','',0,'','ob_chicago'),
			('F20','-2',0,0,0,'','',0,'',''),
			('F22','-10',0,0,0,'','',80,'',''),
			('F24','-3',2,0,0,'','',0,'',''),
			('F4','-10',0,0,0,'','',80,'',''),
			('F6','-105',0,0,0,'Cleveland','',0,'',''),
			('F8','0',0,0,0,'','',0,'',''),
			('G11','0',0,0,0,'','',0,'',''),
			('G13','0',0,0,0,'','',120,'',''),
			('G15','0',0,0,0,'','',120,'',''),
			('G17','-2',0,0,0,'','',0,'',''),
			('G19','-21',1,0,0,'New York','',80,'NY',''),
			('G3','0',0,0,0,'','',0,'',''),
			('G5','0',0,0,0,'','',0,'',''),
			('G7','-2',0,0,0,'','',0,'',''),
			('G9','0',0,0,0,'','',0,'',''),
			('H10','-10',0,0,0,'','',0,'',''),
			('H12','-101',0,0,0,'Altoona','',0,'',''),
			('H14','0',0,0,0,'','',0,'',''),
			('H16','-10',0,0,0,'','',0,'',''),
			('H18','-20',0,0,0,'','',0,'OO',''),
			('H2','0',0,0,0,'','',0,'',''),
			('H4','-10',0,0,0,'','',0,'',''),
			('H6','0',0,0,0,'','',0,'',''),
			('H8','0',0,0,0,'','',0,'',''),
			('I1','-901',5,30,60,'Gulf','',0,'','ob_gulfofmexico'),
			('I11','0',0,0,0,'','',120,'',''),
			('I13','0',0,0,0,'','',0,'',''),
			('I15','-11',0,0,0,'Baltimore','',0,'B',''),
			('I17','0',0,0,0,'','',80,'',''),
			('I19','-3',2,0,0,'','',0,'',''),
			('I3','0',0,0,0,'','',0,'',''),
			('I5','0',0,0,0,'','',0,'',''),
			('I7','0',0,0,0,'','',0,'',''),
			('I9','0',0,0,0,'','',0,'',''),
			('J10','0',0,0,0,'','',120,'',''),
			('J12','0',0,0,0,'','',120,'',''),
			('J14','-10',0,0,0,'Washington','',80,'',''),
			('J2','-902',5,30,60,'Gulf','',0,'','ob_gulfofmexico'),
			('J4','0',0,0,0,'','',0,'',''),
			('J6','0',0,0,0,'','',0,'',''),
			('J8','0',0,0,0,'','',0,'',''),
			('K13','-902',4,30,40,'Deep South','',0,'','ob_deepsouth'),
			('K15','-104',3,0,0,'','',0,'','')
			",
	},
		
	'state_auction' => {
		'count' => 0,
		'sql' => 
			"CREATE TABLE `state_auction` ( 
				id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				private_id VARCHAR DEFAULT ( '' ),
				player_id  INTEGER DEFAULT ( 0 ),
				bid        INTEGER DEFAULT ( 0 ),
				waiting_on INTEGER DEFAULT ( 0 ),
				game_id    VARCHAR DEFAULT ( '' )
			)",
	},
		
	'state_change_stamps' => {
		'count' => 0,
		'sql' =>
			"CREATE TABLE `state_change_stamps` (
				`id` INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
				`game_id` VARCHAR NOT NULL , 
				`stamp_name` VARCHAR NOT NULL , 
				`stamp_value` INTEGER
			)",
	},
		
	'state_corps' => {
		'count' => 0,
		'sql' =>
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
	},
		
	'state_game' => {
		'count' => 0,
		'sql' =>
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
	},
		
	'state_players' => {
		'count' => 0,
		'sql' =>
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
	},
		
	'state_stations' => {
		'count' => 0,
		'sql' =>
			"CREATE TABLE `state_stations` (
				`id` INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
				`game_id` VARCHAR NOT NULL , 
				`space_id` VARCHAR NOT NULL , 
				`station_id` VARCHAR NOT NULL , 
				`slot_id` INTEGER NOT NULL  DEFAULT 0, 
				`corp` VARCHAR NOT NULL 
			)",
	},
		
	'state_tile_locations' => {
		'count' => 0,
		'sql' =>
			"CREATE TABLE `state_tile_locations` ( 
				`id`          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				`game_id`     INTEGER DEFAULT ( '' ),
				`space_id`    VARCHAR DEFAULT ( '' ),
				`tile_id`     VARCHAR DEFAULT ( '' ),
				`orientation` INTEGER DEFAULT ( 0 )
			)",
	},
		
	'stations' => {
		'count' => 53,
		'sql' =>
			"CREATE TABLE `stations` ( 
				`id`         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				`tile_id`    VARCHAR DEFAULT ( '' ),
				`station_id` VARCHAR DEFAULT ( '' ),
				`type`       VARCHAR DEFAULT ( '' ),
				`location`   VARCHAR DEFAULT ( '' ),
				`slots`      INTEGER DEFAULT ( 0 ),
				`revenue`    INTEGER DEFAULT ( 0 ),
				`ignorable`  INTEGER DEFAULT ( 0 )
			)",
		'data' => 
			"INSERT INTO stations (id,tile_id,station_id,type,location,slots,revenue,ignorable) VALUES
			(2,'63','city1','City','0',2,40,0),
			(3,'-902','city1','OffMapCity','0',0,-1,0),
			(4,'55','city2','Town','302',1,10,0),
			(5,'55','city1','Town','202',1,10,0),
			(6,'-903','city1','OffMapCity','0',0,-1,0),
			(7,'-3','city1','Town','252',0,10,0),
			(8,'57','city1','City','0',1,20,0),
			(9,'61','city1','City','0',1,60,0),
			(10,'-104','city1','City','0',1,20,0),
			(11,'-105','city1','City','0',1,30,0),
			(12,'-20','city2','City','302',1,0,0),
			(13,'-20','city1','City','2',1,0,0),
			(14,'-58','city1','Town','301',0,10,0),
			(15,'65','city2','City','252',1,50,0),
			(16,'65','city1','City','501',1,50,0),
			(17,'64','city2','City','52',1,50,0),
			(18,'64','city1','City','401',1,50,0),
			(19,'58','city1','Town','401',0,10,0),
			(20,'15','city1','City','0',2,30,0),
			(21,'-10','city1','City','302',0,0,0),
			(22,'56','city2','Town','108',1,10,0),
			(23,'56','city1','Town','407',1,10,0),
			(24,'66','city2','City','452',1,50,0),
			(25,'66','city1','City','2',1,50,0),
			(26,'-2','city2','Town','302',0,0,0),
			(27,'-2','city1','Town','102',0,0,0),
			(28,'62','city2','City','2',2,80,0),
			(29,'62','city1','City','302',2,80,0),
			(30,'-11','city1','City','0',1,30,0),
			(31,'54','city2','City','552',1,60,0),
			(32,'54','city1','City','352',1,60,0),
			(33,'67','city2','City','502',1,50,0),
			(34,'67','city1','City','307',1,50,0),
			(35,'-901','city1','OffMapCity','0',0,-1,0),
			(36,'68','city2','City','502',1,50,0),
			(37,'68','city1','City','302',1,50,0),
			(38,'2','city1','Town','109',0,10,0),
			(39,'1','city1','Town','108',0,10,0),
			(40,'14','city1','City','0',2,30,0),
			(41,'69','city2','Town','2',1,10,0),
			(42,'69','city1','Town','407',1,10,0),
			(43,'59','city2','City','352',1,40,0),
			(44,'59','city1','City','52',1,40,0),
			(45,'-21','city2','City','502',1,40,0),
			(46,'-21','city1','City','202',1,40,0),
			(47,'-103','city1','City','0',1,40,0),
			(48,'-101','city1','City','0',1,10,1),
			(49,'53','city1','City','0',1,50,0),
			(50,'-102','city1','City','251',1,20,0),
			(51,'-5','city1','City','0',1,20,0),
			(52,'3','city1','Town','352',0,10,0),
			(53,'4','city1','Town','0',0,10,0),
			(54,'-1','city1','Town','2',0,0,0)
			",
	},
		
	'tile_upgrades' => {
		'count' => 63,
		'sql' =>
			"CREATE TABLE `tile_upgrades` ( 
				`id`          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				`tile_id`     VARCHAR DEFAULT ( '' ),
				`new_tile_id` VARCHAR DEFAULT ( '' ) 
			)",
		'data' =>
			"INSERT INTO tile_upgrades (id,tile_id,new_tile_id) VALUES
			(1,'7','18'),
			(2,'7','26'),
			(3,'7','27'),
			(4,'7','28'),
			(5,'7','29'),
			(6,'26','42'),
			(7,'26','44'),
			(8,'26','45'),
			(9,'18','43'),
			(10,'16','43'),
			(11,'16','70'),
			(12,'27','41'),
			(13,'27','44'),
			(14,'27','46'),
			(15,'57','14'),
			(16,'57','15'),
			(17,'20','44'),
			(18,'20','47'),
			(19,'-20','59'),
			(20,'29','39'),
			(21,'29','45'),
			(22,'29','70'),
			(23,'15','63'),
			(24,'19','45'),
			(25,'19','46'),
			(26,'-11','53'),
			(27,'54','62'),
			(28,'25','40'),
			(29,'25','45'),
			(30,'25','46'),
			(31,'28','39'),
			(32,'28','46'),
			(33,'28','70'),
			(34,'14','63'),
			(35,'59','64'),
			(36,'59','65'),
			(37,'59','66'),
			(38,'59','67'),
			(39,'59','68'),
			(40,'-21','54'),
			(41,'24','42'),
			(42,'24','43'),
			(43,'24','46'),
			(44,'24','47'),
			(45,'53','61'),
			(46,'23','41'),
			(47,'23','43'),
			(48,'23','45'),
			(49,'23','47'),
			(50,'9','18'),
			(51,'9','19'),
			(52,'9','20'),
			(53,'9','23'),
			(54,'9','24'),
			(55,'9','26'),
			(56,'9','27'),
			(57,'8','16'),
			(58,'8','19'),
			(59,'8','23'),
			(60,'8','24'),
			(61,'8','25'),
			(62,'8','28'),
			(63,'8','29')
			",
	},
		
	'tiles' => {
		'count' => 65,
		'sql' =>
			"CREATE TABLE tiles ( 
				`tile_id`   VARCHAR PRIMARY KEY NOT NULL,
				`color`     VARCHAR DEFAULT ( '' ),
				`title`     VARCHAR DEFAULT ( '' ),
				`mix_count` INTEGER DEFAULT ( 0 ) 
			)",
		'data' =>
			"INSERT INTO tiles (tile_id,color,title,mix_count) VALUES
			('-903','red','OM 3 way',-1),
			('-902','red','OM 2 way',-1),
			('-901','red','OM 1 way',-1),
			('-105','fixed','MF 105',-1),
			('-104','fixed','MF 104',-1),
			('-103','fixed','MF 103',-1),
			('-102','fixed','-102',-1),
			('-101','fixed','Philadelphia',-1),
			('-58','fixed','MF 58',-1),
			('-21','yellow','NY',-1),
			('-20','yellow','2 cities',-1),
			('-11','yellow','B',-1),
			('-10','white','1 city',-1),
			('-7','fixed','MF 7',-1),
			('-5','fixed','MF 5',-1),
			('-3','fixed','MF 3',-1),
			('-2','white','2 villages',-1),
			('-1','white','1 village',-1),
			('0','white','empty',-1),
			('1','yellow','1',1),
			('2','yellow','2',1),
			('3','yellow','3',2),
			('4','yellow','4',2),
			('7','yellow','7',4),
			('8','yellow','8',8),
			('9','yellow','9',7),
			('14','green','14',3),
			('15','green','15',2),
			('16','green','16',1),
			('18','green','18',1),
			('19','green','19',1),
			('20','green','20',1),
			('23','green','23',3),
			('24','green','24',3),
			('25','green','25',1),
			('26','green','26',1),
			('27','green','27',1),
			('28','green','28',1),
			('29','green','29',1),
			('39','brown','39',1),
			('40','brown','40',1),
			('41','brown','41',2),
			('42','brown','42',2),
			('43','brown','43',2),
			('44','brown','44',1),
			('45','brown','45',2),
			('46','brown','46',2),
			('47','brown','47',1),
			('53','green','53',2),
			('54','green','54',1),
			('55','yellow','55',1),
			('56','yellow','56',1),
			('57','yellow','57',4),
			('58','yellow','58',2),
			('59','green','59',2),
			('61','brown','61',2),
			('62','brown','62',1),
			('63','brown','63',3),
			('64','brown','64',1),
			('65','brown','65',1),
			('66','brown','66',1),
			('67','brown','67',1),
			('68','brown','68',1),
			('69','yellow','69',1),
			('70','brown','70',1)
			",
	},
		
	'tracks' =>	{
		'count' => 168,
		'sql' => 
			"CREATE TABLE `tracks` ( 
				`id`      		INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				`tile_id` 		VARCHAR DEFAULT ( '' ),
				`start_point`	VARCHAR DEFAULT ( '' ),
				`end_point`		VARCHAR DEFAULT ( '' )
			)",
		'data' =>
			"INSERT INTO tracks (id,tile_id,start_point,end_point) VALUES
			(7,'63','city1','side0'),
			(8,'63','city1','side1'),
			(9,'63','city1','side2'),
			(10,'63','city1','side3'),
			(11,'63','city1','side4'),
			(12,'63','city1','side5'),
			(13,'7','side3','side4'),
			(14,'26','side0','side3'),
			(15,'26','side0','side5'),
			(16,'-902','city1','side2'),
			(17,'-902','city1','side1'),
			(18,'18','side0','side3'),
			(19,'18','side4','side5'),
			(20,'16','side0','side4'),
			(21,'16','side5','side3'),
			(22,'44','side0','side3'),
			(23,'44','side0','side1'),
			(24,'44','side4','side3'),
			(25,'44','side4','side1'),
			(26,'55','city1','side2'),
			(27,'55','city1','side5'),
			(28,'55','city2','side3'),
			(29,'55','city2','side0'),
			(30,'-903','city1','side3'),
			(31,'-903','city1','side2'),
			(32,'-903','city1','side1'),
			(33,'-3','city1','side2'),
			(34,'-3','city1','side3'),
			(35,'27','side0','side3'),
			(36,'27','side4','side3'),
			(37,'57','city1','side3'),
			(38,'57','city1','side0'),
			(39,'61','city1','side0'),
			(40,'61','city1','side1'),
			(41,'61','city1','side3'),
			(42,'61','city1','side5'),
			(43,'-104','city1','side2'),
			(44,'20','side0','side3'),
			(45,'20','side1','side4'),
			(46,'-105','city1','side2'),
			(47,'-105','city1','side3'),
			(48,'-7','side1','side2'),
			(49,'-58','city1','side2'),
			(50,'-58','city1','side4'),
			(51,'65','city1','side4'),
			(52,'65','city1','side0'),
			(53,'65','city2','side2'),
			(54,'65','city2','side3'),
			(55,'29','side5','side3'),
			(56,'29','side4','side3'),
			(57,'39','side3','side4'),
			(58,'39','side5','side3'),
			(59,'39','side4','side5'),
			(60,'64','city1','side3'),
			(61,'64','city1','side5'),
			(62,'64','city2','side1'),
			(63,'64','city2','side0'),
			(64,'41','side3','side0'),
			(65,'41','side4','side3'),
			(66,'41','side0','side4'),
			(67,'58','city1','side5'),
			(68,'58','city1','side3'),
			(69,'15','city1','side0'),
			(70,'15','city1','side4'),
			(71,'15','city1','side5'),
			(72,'15','city1','side3'),
			(73,'56','city1','side2'),
			(74,'56','city1','side4'),
			(75,'56','city2','side3'),
			(76,'56','city2','side1'),
			(77,'66','city1','side3'),
			(78,'66','city1','side0'),
			(79,'66','city2','side4'),
			(80,'66','city2','side5'),
			(81,'45','side0','side3'),
			(82,'45','side0','side5'),
			(83,'45','side1','side5'),
			(84,'45','side3','side1'),
			(85,'19','side0','side3'),
			(86,'19','side1','side5'),
			(87,'62','city1','side3'),
			(88,'62','city1','side4'),
			(89,'62','city2','side5'),
			(90,'62','city2','side0'),
			(91,'-11','city1','side1'),
			(92,'-11','city1','side3'),
			(93,'54','city1','side3'),
			(94,'54','city1','side4'),
			(95,'54','city2','side5'),
			(96,'54','city2','side0'),
			(97,'67','city1','side1'),
			(98,'67','city1','side3'),
			(99,'67','city2','side5'),
			(100,'67','city2','side2'),
			(101,'70','side0','side4'),
			(102,'70','side0','side5'),
			(103,'70','side4','side3'),
			(104,'70','side5','side3'),
			(105,'-901','city1','side2'),
			(106,'68','city1','side3'),
			(107,'68','city1','side0'),
			(108,'68','city2','side2'),
			(109,'68','city2','side5'),
			(110,'2','city1','side0'),
			(111,'2','city1','side3'),
			(112,'2','city2','side1'),
			(113,'2','city2','side2'),
			(114,'1','city1','side0'),
			(115,'1','city1','side4'),
			(116,'1','city2','side1'),
			(117,'1','city2','side3'),
			(118,'25','side1','side3'),
			(119,'25','side5','side3'),
			(120,'28','side5','side3'),
			(121,'28','side5','side4'),
			(122,'40','side1','side3'),
			(123,'40','side1','side5'),
			(124,'40','side5','side3'),
			(125,'14','city1','side0'),
			(126,'14','city1','side1'),
			(127,'14','city1','side3'),
			(128,'14','city1','side4'),
			(129,'69','city1','side2'),
			(130,'69','city1','side4'),
			(131,'69','city2','side3'),
			(132,'69','city2','side0'),
			(133,'59','city1','side1'),
			(134,'59','city2','side3'),
			(135,'-21','city1','side2'),
			(136,'-21','city2','side5'),
			(137,'24','side0','side3'),
			(138,'24','side5','side3'),
			(139,'-103','city1','side2'),
			(140,'-103','city1','side3'),
			(141,'-101','city1','side1'),
			(142,'-101','city1','side4'),
			(143,'-101','side4','side1'),
			(144,'53','city1','side1'),
			(145,'53','city1','side3'),
			(146,'53','city1','side5'),
			(147,'42','side5','side0'),
			(148,'42','side5','side3'),
			(149,'42','side0','side3'),
			(150,'-102','city1','side1'),
			(151,'-102','city1','side3'),
			(152,'-102','city1','side4'),
			(153,'46','side0','side3'),
			(154,'46','side1','side0'),
			(155,'46','side3','side5'),
			(156,'46','side1','side5'),
			(157,'23','side0','side3'),
			(158,'23','side0','side4'),
			(159,'-5','city1','side2'),
			(160,'-5','city1','side1'),
			(161,'3','city1','side3'),
			(162,'3','city1','side4'),
			(163,'9','side3','side0'),
			(164,'47','side0','side4'),
			(165,'47','side0','side3'),
			(166,'47','side1','side4'),
			(167,'47','side3','side1'),
			(168,'8','side3','side5'),
			(169,'4','city1','side3'),
			(170,'4','city1','side0'),
			(171,'43','side0','side3'),
			(172,'43','side0','side4'),
			(173,'43','side5','side3'),
			(174,'43','side5','side4')
			",			
	},
);

#############################################################################

sub create_tables {
	my $connection		= shift;
	
	foreach my $table_name ( sort( keys( %_tables ) ) ) {
		$connection->simple_exec( $_tables{ $table_name }->{'sql'} );
		
		my $exists = $connection->simple_value( 0, "select COUNT( name ) AS value FROM sqlite_master WHERE type='table' AND name=?", $table_name );
		
		if ( $exists ) {
			print "\nCreated table $table_name ... ";
			
			if ( $_tables{ $table_name }->{'count'} > 0 ) {
			
				$connection->simple_exec( $_tables{ $table_name }->{'data'} );
			
				my $count = $connection->simple_value( 0, "SELECT COUNT(*) AS value FROM $table_name" );
				if ( $count == $_tables{ $table_name }->{'count'} ) {
					print "created $count records ... done.";
				}
				else {
					print "failed to create $count records.";
				}			
			}
			else {
				print "done.";
			}
		}
		else {
			print "\nFailed to create table $table_name.";
		}
		
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
		$connection->simple_exec( 'DROP TABLE IF EXISTS ' . $table_name . '; VACUUM;' );
	}
	
	return;
}		

#############################################################################
#############################################################################
1