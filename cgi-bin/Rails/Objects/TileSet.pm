package Rails::Objects::TileSet;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );
	use Rails::Objects::Tile;

	my @tiles		:Field		:Default( undef );

	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set( \@tiles, {} );
		
		
		
		return;
	}
	
	#############################################

	sub load {
		my $self		= shift;

		my @records = $self->connection()->sql(	"SELECT * FROM tiles" );
		
		foreach my $record ( @records ) {
			my $tile = Rails::Objects::Tile->new( 'connection' => $self->connection() );
			$tile->parse_from_record( $record );
			
			$tiles[ $$self ]->{ $tile->get_id() } = $tile;
		}
		
		return;
	}
	
	#############################################

	sub tile {
		my $self		= shift;
		my $tag			= shift;
		
		return $tiles[ $$self ]->{ $tag };		
	}
	
	#############################################

	sub tile_ids {
		my $self		= shift;
		
		return keys( %{ $tiles[ $$self ] } );
	}	
	

	#############################################
	#############################################
	
}


#############################################################################





#############################################################################
#############################################################################
1