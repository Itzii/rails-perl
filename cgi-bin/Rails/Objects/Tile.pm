package Rails::Objects::Tile;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );

	my @color	:Field		:Type( scalar )		:Default( 'white' )	:Std(color)		:Arg(color);
	my @name	:Field		:Type( scalar )		:Default( '' )		:Std(name)		:Arg(name);
	
	my @label	:Field		:Type( scalar )		:Default( '' )		:Std(label);
	
	my @stations	:Field						:Default( undef )	:Get(stations);
	my @tracks		:Field						:Default( undef )	:Get(tracks);
	my @upgrades	:Field						:Default( undef )	:Get(upgrades);
	my @count		:Field	:Type( numeric )	:Default( -1 )		:Std(count);
	
	my %init_args 		:InitArgs = ( 
		'tag' 	=> '', 
	);
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		my $args	= shift;
		
		$self->set_doctype( 'Tile' );

		$self->set( \@stations, {} );
		$self->set( \@tracks, {} );
		$self->set( \@upgrades, [] );
		
		if ( exists( $args->{'tag'} ) ) {
			$self->set_id( $args->{'tag'} );          
		}
		
		return;
	}

	#############################################

	sub parse_from_record {
		my $self		= shift;
		my $record		= shift;
		
		$self->set_id( $record->{'tile_id'} );
		$self->set_color( $record->{'color'} );
		$self->set_name( $record->{'title'} );
		$self->set_count( $record->{'mix_count'} );
		
		my @records = $self->connection()->sql(
			"SELECT * FROM stations WHERE tile_id=?",
			$self->get_id(),
		);
		
		foreach my $record ( @records ) {
			my %station = (
				'id'		=> $record->{'station_id'},
				'position'	=> $record->{'location'},
				'type'		=> $record->{'type'},
				'slots'		=> $record->{'slots'},
				'value'		=> $record->{'revenue'},
			);
			
			$self->stations()->{ $record->{'station_id'} } = \%station;
		}
		
		@records = $self->connection()->sql(
			"SELECT * FROM tracks WHERE tile_id=?",
			$self->get_id(),
		);
		
		foreach my $record ( @records ) {
			my $tag = $record->{'start_point'} . ':' . $record->{'end_point'};
			$self->tracks()->{ $tag } = [ $record->{'start_point'}, $record->{'end_point'} ];
		}
		
		@records = $self->connection()->sql(
			"SELECT * FROM tile_upgrades WHERE tile_id=?",
			$self->get_id(),
		);
		
		foreach my $record ( @records ) {
			push( @{ $upgrades[ $$self ] }, $record->{'new_tile_id'} );
		}
		
		$self->clear_flags;
		
		return;
	}		
		
	#############################################

	sub node_connects_to {
		my $self		= shift;
		my $location	= shift;
	
		my @tracks = ();
		
		foreach my $track_tag ( keys( %{ $self->tracks() } ) ) {
			if ( $self->tracks()->{ $track_tag }->[ 0 ] eq $location ) {
				push( @tracks, $self->tracks()->{ $track_tag }->[ 1 ] );
			}
			elsif ( $self->tracks()->{ $track_tag }->[ 1 ] eq $location ) {
				push( @tracks, $self->tracks()->{ $track_tag }->[ 0 ] );
			}
		}
		
		return @tracks;
	}
		
	#############################################

	sub value_of_node {
		my $self		= shift;
		my $location	= shift;
		
		unless ( defined( $self->stations()->{ $location } ) ) {
			return 0;
		}
		
		return $self->stations()->{ $location }->{'value'};
	}	
	

	#############################################
	#############################################
	
}


#############################################################################


	
#############################################################################



#############################################################################
#############################################################################
1