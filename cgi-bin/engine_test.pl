#!/usr/bin/perl

use strict;
use warnings;

use Rails::Objects::Game;
use Rails::Objects::Connection;

$| = 1;

print "\n";

my $game = Rails::Objects::Game->new( 'connection' => Rails::Objects::Connection->new( 'database' => 'testrails.sqlite' ) );
$game->load_state( 'TiXsVnVlCEB6' );

my %cases = (
	'case 1:'	=> { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '2', 'value' => '60' },
	'case 2:'	=> { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '3', 'value' => '90' },
	'case 3:'	=> { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '4', 'value' => '100' },
	'case 4:'	=> { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '5', 'value' => '130' },	
	'case 5:'	=> { 'start' => 'H10.city1', 'corp' => 'bo', 'train' => '6', 'value' => '140' },
	'case 6:'	=> { 'start' => 'D2.city1', 'corp' => 'co', 'train' => '6', 'value' => '170' },
	
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

print "\n";
