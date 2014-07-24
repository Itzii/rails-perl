package Rails::Objects::Map;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );
	use Rails::Objects::MapSpace;
	use Rails::Objects::TileSet;
	use Rails::Objects::RouteList;

	my @spaces		:Field		:Default( undef )		:Get(spaces);
	my @tile_set	:Field		:Default( undef )		:Get(tile_set);
	my @game		:Field		:Default( undef )		:Get(game)		:Arg( 'name' => 'game', 'Mandatory' => 1 );
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set( \@spaces, {} );
		
		$self->load();
		
		return;
	}
	
	#############################################

	sub space {
		my $self 	= shift;
		my $tag		= shift;
		
		if ( defined( $self->spaces()->{ $tag } ) ) {
			return $self->spaces()->{ $tag };
		}
		
		return undef;		
	}
	
	#############################################

	sub tile {
		my $self	= shift;
		my $tag		= shift;
		
		my $space = $self->space( $tag );
		
		unless ( defined( $space ) ) {
			return undef;
		}
		
		return $self->tile_set()->tile( $space->get_tile_id() );
	}

	#############################################

	sub load {
		my $self	= shift;
		
		$self->set( \@tile_set, Rails::Objects::TileSet->new( 'connection' => $self->connection() ) );

		my @records = $self->connection()->sql( "SELECT * FROM map_spaces" );
		
		foreach my $record ( @records ) {
			my $space = Rails::Objects::MapSpace->new( 'connection' => $self->connection(), 'tile_set' => $self->tile_set() );
			$space->parse_from_record( $record );
			
			$self->spaces()->{ $space->get_id() } = $space;
		}
		
		$self->tile_set()->load();
			
		return;		
	}
	
	#############################################

	sub load_state {
		my $self	= shift;
		my $game_id	= shift;
		
		foreach my $space_id ( keys( %{ $self->spaces() } ) ) {
			$self->spaces()->{ $space_id }->load_state( $game_id );
		}

		return;
	}	
	
	#############################################

	sub save_state {
		my $self	= shift;
		my $game_id	= shift;
		
		if ( $self->has_changed() == 0 ) {
			return;
		}
		
		foreach my $space_id ( keys( %{ $self->spaces() } ) ) {
			$self->space( $space_id )->save_state( $game_id );
		}
		
		$self->clear_changed();
		
		return;
	}

	#############################################

	sub create_state {
		my $self	= shift;
		my $game_id	= shift;
		
		foreach my $space_id ( keys( %{ $self->spaces() } ) ) {
			$self->space( $space_id )->create_state( $game_id );
		}
		
		return;
	}
	
	#############################################

	sub stations_for_corp {
		my $self	= shift;
		my $corp	= shift;
		
		
	
		return ();
	}

	#############################################

	sub best_routes {
		my $self		= shift;
		my $corp		= shift;
		
		my @stations = $self->stations_for_corp( $corp->get_id() );
		
		foreach my $train ( @{ $corp->trains() } ) {
		
			my $routes = Rails::Objects::RouteList->new( 'map' => $self, 'corp' => $corp->get_id() );
			
			foreach my $node ( @stations ) {
				$routes = $routes + $self->routes_through_node( $node, $train, $corp->get_id() );
			}
			
			
		
		
		
		
		
		
		}
		
		
		
	}

	#############################################

	sub routes_through_node {
		my $self		= shift;
		my $start_node	= shift;
		my $max_length	= shift;
		my $corp_tag	= shift;
		
		if ( $max_length eq 'D' ) {
			$max_length = -1;
		}
		
		my $route_list = Rails::Objects::RouteList->new( 'map' => $self, 'corp' => $corp_tag );
		$route_list->generate_from_node( $start_node, $max_length );
		
		return $route_list;		
	}

	#############################################

	sub node_connects_to {
		my $self		= shift;
		my $node		= shift;
		
		my ( $space ) = split( /\./, $node );

		unless ( defined( $self->spaces()->{ $space } ) ) {
			return ();
		}

		my @locals = $self->spaces()->{ $space }->node_connects_to( $node );
		my %nodes = ();
		
		foreach my $local_node ( @locals ) {
			$nodes{ $local_node } = 1;
		}
		
		
		if ( $node =~ m{ side(\d{1}) $ }xms ) {
			my $direction = $1;
			my $reverse_direction = $direction + 3;
			if ( $reverse_direction > 5 ) {
				$reverse_direction -= 6;
			}
		
			my $new_space = $self->space_in_direction( $space, $direction );
			
			if ( defined( $self->spaces()->{ $new_space } ) ) {
				$nodes{ $new_space . '.side' . $reverse_direction } = 1;
			}
		}
			
		return keys( %nodes );
	}
	
	#############################################

	sub value_of_node {
		my $self		= shift;
		my $node		= shift;
		my $high_low	= shift;
		
		my ( $space ) = split( /\./, $node );
		
		unless ( defined( $self->spaces()->{ $space } ) ) {
			print "\n*** space ($space) is undefined";
			return 0;
		}

#		print "\n*** space ($space) is defined with a value";
		return $self->spaces()->{ $space }->value_of_node( $node, $high_low );
	}

	#############################################

	sub high_low {
		my $self	= shift;
		
		return ( $self->game()->get_current_phase() >= 5 ) ? 1 : 0;
	}

	#############################################

	sub can_corp_trace_through_node {
		my $self	= shift;
		my $node	= shift;
		my $corp	= shift;
		
		my ( $space, $local_node ) = split( /\./, $node );
		
		if ( ! defined( $self->spaces()->{ $space } ) ) {
			return 0;
		}
		
		return $self->spaces()->{ $space }->can_corp_trace_through_station( $local_node, $corp );
	}
	
	#############################################

	sub space_in_direction {
		my $self		= shift;
		my $space		= shift;
		my $direction	= shift;
		
		$space =~ m{ ([A-Z]{1})(\d{1,2}) }xms;
		
		my $row = $1;
		my $column = $2;
		
		my $new_column 	= undef;
		my $new_row		= undef;
		
		
		
		if ( $direction == 0 || $direction == 2 ) {
			$column += 1;
		}
		elsif ( $direction == 1 ) {
			$column += 2;
		}
		elsif ( $direction == 3 || $direction == 5 ) {
			$column -= 1;
		}
		else {
			$column -= 2;
		}
		
		my @rows = ( '', 'A' .. 'K', '' );
		
		my $row_index = -1;
		my $current_index = 0;
		foreach my $letter ( @rows ) {
			if ( $letter eq $row ) {
				$row_index = $current_index;
				last;
			}
			$current_index++;
		}

		if ( $direction == 1 || $direction == 4 ) {
			$new_row = $row_index;
		}
		elsif ( $direction == 0 || $direction == 5 ) {
			$new_row = $row_index - 1;
		}
		else {
			$new_row = $row_index + 1;
		}
		
		return $rows[ $new_row ] . $column;
	}		

	#############################################
	#############################################
	
}



#############################################################################
#############################################################################
1