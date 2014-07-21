package Rails::Objects::MapSpace;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );
	
	my @tile_set	:Field						:Default( undef )		:Get(tile_set)		:Arg( 'Name' => 'tile_set', 'Mandatory' => 1 );

	my @minor		:Field	:Type( numeric )	:Default( 0 )			:Std(minor)			:Arg(minor);
	my @major		:Field	:Type( numeric )	:Default( 0 )			:Std(major)			:Arg(major);
	my @impassable	:Field	:Type( scalar )		:Default( '' )			:Std(impassable)	:Arg(impassable);
	my @label		:Field	:Type( scalar )		:Default( '' )			:Std(label)			:Arg(label);
	my @cost		:Field	:Type( numeric )	:Default( 0 )			:Std(cost)			:Arg(cost);
	my @city		:Field	:Type( scalar )		:Default( '' )			:Std(city)			:Arg(city);
	my @ob_city		:Field	:Type( scalar )		:Default( '' )			:Std(ob_city)		:Arg(ob_city);

	my @tile_id		:Field	:Type( numeric )	:Default( 0 )			:Get(get_tile_id)		:Arg(tile_id);
	my @orientation :Field	:Type( numeric )	:Default( 0 )			:Get(get_orientation)	:Arg(orientation);
	my @stations	:Field						:Default( undef )		:Get(stations);	
	
	my %init_args 		:InitArgs = ( 
		'tag' 	=> '', 
	);

	#############################################
	
	sub _init :Init {
		my $self	= shift;
		my $args	= shift;
		
		$self->set_doctype( 'MapSpace' );
		
		if ( exists( $args->{'tag'} ) ) {
			$self->set_id( $args->{'tag'} );          
		}
		
		$self->set( \@stations, {} );
		
		return;		
	}

	#############################################
	
	sub clear {
		my $self	= shift;
		
		$self->Base::Objects::Base::clear();
		
		$self->set( \@minor, 0 );
		$self->set( \@major, 0 );
		$self->set( \@impassable, '' );
		$self->set( \@label, '' );
		$self->set( \@cost, 0 );
		$self->set( \@city, '' );
		$self->set( \@ob_city, '' );
		$self->set( \@tile_id, 0 );
		$self->set( \@orientation, 0 );
		$self->set( \@stations, {} );
		
		$self->set_doctype( 'MapSpace' );

		return;
	}

	#############################################

	sub parse_from_record {
		my $self	= shift;
		my $record	= shift;
		
		$self->clear();
		
		$self->set_id( $record->{ 'id' } );
		$self->set_tile_id( $record->{ 'tile_id' } );
		$self->set_orientation( $record->{ 'orientation' } );
		$self->set_minor( $record->{ 'minor' } );
		$self->set_major( $record->{ 'major' } );
		$self->set_impassable( $record->{ 'impassable' } );
		$self->set_label( $record->{ 'label' } );
		$self->set_cost( $record->{ 'cost' } );
		$self->set_city( $record->{ 'city' } );
		$self->set_ob_city( $record->{ 'ob_city' } );
		
		$self->make_valid();
		$self->clear_flags();
		
		return $self->is_valid();
	}

	#############################################

	sub load_state {
		my $self	= shift;
		my $game_id	= shift;
		
		my @records = $self->connection()->sql(
			"SELECT * FROM state_tile_locations WHERE game_id=? AND space_id=?",
			$game_id, $self->get_id()
		);
		
		unless ( @records ) {
			return;
		}
		
		$self->set_tile_id( $records[ 0 ]->{'tile_id'} );
		$self->set_orientation( $records[ 0 ]->{'orientation'} );
		
		
		@records = $self->connection()->sql(
			"SELECT * FROM state_stations WHERE game_id=? AND space_id=? ORDER BY station_id, slot_id",
			$game_id, $self->get_id(),
		);
		
		foreach my $record ( @records ) {
			$self->stations()->{ $record->{'station_id'} }->{ $record->{'slot_id'} } = $record->{'corp'};
		}
		
		$self->clear_flags();
		
		return;
	}

	#############################################

	sub set_tile_id {
		my $self	= shift;
		my $value	= shift;
		
		$self->set( \@tile_id, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub set_orientation {
		my $self	= shift;
		my $value	= shift;
		
		$self->set( \@orientation, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub save_state {
		my $self		= shift;
		my $game_id		= shift;

		unless ( $self->has_changed() == 1 ) {
			return;
		}
		
		$self->connection()->simple_exec(
			"UPDATE state_tile_locations SET 
			tile_id=?, orientation=?
			WHERE game_id=? AND space_id=?",
			$self->get_tile_id(), $self->get_orientation(), $game_id, $self->get_id(),
		);
		
		foreach my $station_id ( keys( %{ $self->tile()->stations() } ) ) {
			foreach my $slot_id ( keys( %{ $self->tile()->stations()->{ $station_id } } ) ) {
				$self->connection()->simple_exec(
					"UPDATE state_stations SET corp=?
					WHERE game_id=? AND space_id=? AND station_id=? AND slot_id=?",
					$self->tile()->stations()->{ $station_id }->{ $slot_id },
					$game_id, $self->get_id(), $station_id, $slot_id
				);
			}
		}
		
		
		$self->clear_flags();
		
		return;		
	}

	#############################################

	sub create_state {
		my $self		= shift;
		my $game_id		= shift;
		
		$self->connection()->simple_exec(
			"INSERT INTO state_tile_locations ( game_id, space_id, tile_id, orientation )
			VALUES ( ?, ?, ?, ? )",
			$game_id, $self->get_id(), $self->get_tile_id(), $self->get_orientation(),
		);		
		
		
		foreach my $station_id ( keys( %{ $self->tile()->stations() } ) ) {
			foreach my $slot_id ( 0 .. $self->tile()->stations()->{ $station_id }->{'slots'} - 1 ) {
				$self->create_station( $game_id, $station_id, $slot_id );
			}
		}
		
		return;
	}

	
	#############################################

	sub create_station {
		my $self		= shift;
		my $game_id		= shift;
		my $station_id	= shift;
		my $new_slot_id	= shift;
		
		$self->connection()->simple_exec(
			"INSERT INTO state_stations ( game_id, space_id, station_id, slot_id, corp )
			VALUES( ?, ?, ?, ?, '' )",
			$game_id, $self->get_id(), $station_id, $new_slot_id
		);
		
		return;
	}		

	#############################################

	sub tile {
		my $self		= shift;
		
		return $self->tile_set()->tile( $self->get_tile_id() );
	}

	#############################################

	sub stations_for_corp {
		my $self	= shift;
		my $corp	= shift;
		
		my @stations = ();
		
		foreach my $station_id ( keys( %{ $self->tile()->stations() } ) ) {
		
			my $slot_count = $self->tile()->stations()->{ $station_id }->{'slots'};
			my $station = $self->stations()->{ $station_id };
		
			foreach my $current_slot ( 0 .. $slot_count - 1 ) {
				if ( $station->{ $current_slot } eq $corp ) {
					push( @stations, $station_id );
				}
			}
		}
		
		return @stations;
	}

	#############################################

	sub add_station {
		my $self		= shift;
		my $station_id	= shift;
		my $corp		= shift;
		
		if ( ! defined( $self->tile()->stations()->{ $station_id } ) ) {
			return 0;
		}
		
		my $slot_count = $self->tile()->stations()->{ $station_id }->{'slots'};
		my $station = $self->stations()->{ $station_id };
		
		my $current_slot = 0;		
		while ( $current_slot < $slot_count ) {
			if ( $station->{ $current_slot } eq '' ) {
				$station->{ $current_slot } = $corp;
				$self->changed();
				return 1;
			}				
			$current_slot++;
		}
		
		return 0;
	}
	
	#############################################

	sub can_corp_trace_through_station {
		my $self		= shift;
		my $station_id	= shift;
		my $corp		= shift;
		
		if ( ! defined( $self->tile()->stations()->{ $station_id } ) ) {
			return 1;
		}
		
		my $slot_count = $self->tile()->stations()->{ $station_id }->{'slots'};
		my $station = $self->stations()->{ $station_id };
		
		# TODO if not defined, is that a bug?
		unless ( defined( $station ) ) {
			return 1;
		}
		
		foreach my $current_slot ( 0 .. $slot_count - 1 ) {
				
			if ( $station->{ $current_slot } eq '' || $station->{ $current_slot } eq $corp ) {
				return 1;
			}
		}
		
		return 0;
	}
	
	#############################################

	sub outer_to_inner {
		my $self		= shift;
		my $location	= shift;
		
		my ( $space, $local_name ) = split( /\./, $location );

		if ( $local_name !~ m{ ^ side(\d{1}) $ }xms ) {
			return $local_name;
		}
		
		my $outer_side = $1;
		my $inner_side = $outer_side - $self->get_orientation();
			
		while ( $inner_side < 0 ) {
			$inner_side += 6;
		}
			
		return 'side' . $inner_side;
	}
		
	#############################################

	sub inner_to_outer {
		my $self		= shift;
		my $location	= shift;
		
		if ( $location !~ m{ ^ side(\d{1}) $ }xms ) {
			return $self->get_id() . '.' . $location;
		}

		my $inner_side = $1;
		my $outer_side = $inner_side + $self->get_orientation();
				
		while ( $outer_side > 5 ) {
			$outer_side -= 6;
		}
				
		return $self->get_id() . '.side' . $outer_side;
	}
		
		
	#############################################

	sub node_connects_to {
		my $self		= shift;
		my $location	= shift;
		
		my $local_name = $self->outer_to_inner( $location );
		
		my @ends = $self->tile()->node_connects_to( $local_name );
		my @adjusted_ends = ();
		
		foreach my $local_end ( @ends ) {
		
			if ( $self->get_ob_city() eq '' ) {
				push( @adjusted_ends, $self->inner_to_outer( $local_end ) );
			}
			elsif ( $local_end !~ m{ ^ side }xmsi ) {
				push( @adjusted_ends, $self->get_id() . '.+' . $self->get_ob_city() );				
			}
			else {
				print "\nIgnoring connection to $location ";
			}
			
		}
		
		return @adjusted_ends;
	}	
	
	#############################################

	sub value_of_node {
		my $self		= shift;
		my $location	= shift;
		my $high_low	= shift;
		
		my $local_name = $self->outer_to_inner( $location );
		
		if ( $local_name =~ m{ ^ \+ }xms ) {
				
			if ( $high_low == 0 ) {
				return $self->get_minor();
			}
			return $self->get_major();
		}
		
		return $self->tile()->value_of_node( $local_name );
	}

	#############################################
	#############################################
	
}


	
#############################################################################















#############################################################################
#############################################################################
1