package Rails::Objects::Corp;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Objects::Holder );
	
	my @long_name			:Field	:Default('')			:Get(get_long_name);
	my @short_name			:Field	:Default('')			:Get(get_short_name);
	my @stations			:Field	:Default('')			:Get(get_stations);
	my @start_tile			:Field	:Default('')			:Get(get_start_tile);
	my @start_city			:Field	:Default('')			:Get(get_start_city);
	my @par_price			:Field							:Get(get_par_price);
	my @current_price		:Field							:Get(get_current_price);
	my @current_index		:Field	:Default( 0 )			:Get(get_current_index);
	my @current_position	:Field	:Default( '-1,-1' )		:Get(get_current_position);
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set_doctype( 'Corp' );
		
		$self->set( \@long_name, '' );
		$self->set( \@short_name, '' );
		$self->set( \@stations, '' );
		$self->set( \@start_tile, '' );
		$self->set( \@start_city, '' );
		$self->set( \@par_price, 0.00 );
		$self->set( \@current_price, 0.00 );
		$self->set( \@current_index, 0 );
		$self->set( \@current_position, '-1,-1' );
		
		return;
	}
	
	#############################################

	sub clear {
		my $self 	= shift;

		$self->Rails::Objects::Holder::clear();
		
		$self->set( \@long_name, '' );
		$self->set( \@short_name, '' );
		$self->set( \@stations, '' );
		$self->set( \@start_tile, '' );
		$self->set( \@start_city, '' );
		$self->set( \@par_price, 0 );
		$self->set( \@current_price, 0.00 );
		$self->set( \@current_index, 0.00 );
		$self->set( \@current_position, '-1,-1' );

		return;
	}

	#############################################

	sub load {
		my $self		= shift;
		my $id			= shift;
		
		my @records = $self->connection()->sql( "SELECT * FROM corps WHERE id=?", $id );
		
		unless ( @records ) {
			return 0;
		}
		
		my $record = shift( @records );
		
		$self->set_id( $id );
		$self->set_long_name( $record->{'name_long'} );
		$self->set_short_name( $record->{'name_short'} );
		$self->set_stations( $record->{'station'} );
		$self->set_start_tile( $record->{'start_tile'} );
		$self->set_start_city( $record->{'start_city'} );
	
		return 1;
	}

	#############################################

	sub load_state {
		my $self		= shift;
		my $game_id		= shift;
		
		my @records = $self->connection()->sql( 
			"SELECT * FROM state_corps WHERE game_id=? AND corp_id=?", 
			$game_id, 
			$self->get_id() 
		);
		
		unless ( @records ) {
			return 0;
		}
		
		my $record = shift( @records );
	
		$self->set_cash( $record->{'cash'} );
		
		
		$self->set_stations( $record->{'stations'} );
		
		$self->trains_from_text( $record->{'trains'} );
		$self->privates_from_text( $record->{'privates'} );
		$self->shares_from_text( $record->{'shares'} );

		$self->set_par_price( $record->{'par_price'} );
		
		$self->set_current_price( $record->{'current_price'} );
		$self->set_current_index( $record->{'current_index'} );
		$self->set_current_position( $record->{'current_position'} );
		
		return 1;
	}
	
	#############################################

	sub create_state {
		my $self		= shift;
		my $game_id		= shift;
		
		$self->add_shares( $self->get_id(), 10 );
		
		$self->connection()->sql(
			"INSERT INTO state_corps ( game_id, corp_id, cash, trains, privates, stations, 
			shares, par_price, current_price, current_index, current_position )
			VALUES ( ?, ?, 0, '', '', ?, ?, 0, 0, 0, '-1,-1' )",
			$game_id, $self->get_id(), $self->get_stations(), $self->shares_text(),
		);
		
		return;
	}

	#############################################

	sub save_state {
		my $self		= shift;
		
		if ( $self->has_changed() == 0 ) {
			return;
		}
		
		$self->connection()->sql( 
			"UPDATE state_corps SET
			cash=?, trains=?, privates=?, stations=?, shares=?, 
			par_price=?, current_price=?, current_index=?, current_position=?
			WHERE game_id=? AND corp_id=?",
			$self->get_cash(), $self->trains_text(),
			$self->privates_text(),
			$self->get_stations(),
			$self->shares_text(),
			$self->get_par_price(),
			$self->get_current_price(),
			$self->get_current_index(),
			$self->get_current_position(),
			$self->game()->get_id(), $self->get_id()
		);
		
		$self->clear_changed();
		
		return;
	}

	#############################################

	sub set_long_name {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@long_name, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub set_short_name {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@short_name, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub set_stations {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@stations, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub set_start_tile {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@start_tile, $value );
		$self->changed();
		
		return;
	}

	#############################################

	sub set_start_city {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@start_city, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub set_par_price {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@par_price, $value );
		$self->changed();
		
		return;
	}

	#############################################

	sub set_current_price {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@current_price, $value );
		$self->changed();
		
		return;
	}

	#############################################

	sub set_current_index {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@long_name, $value );
		$self->changed();
		
		return;
	}

	#############################################

	sub set_current_position {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@current_position, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub cost_of_next_station {
		my $self	= shift;
		
		my @values = split( /,/, $self->get_station() );
		
		unless ( @values ) {
			return -1;
		}
		
		return shift( @values );
	}		
	
	#############################################

	sub remove_station {
		my $self	= shift;
		
		my @values = split( /,/, $self->get_station() );
		
		unless ( @values ) {
			$self->set_station( '' );
			return;
		}
		
		shift( @values );
		
		$self->set_stations( join( ',', @values ) );
		
		$self->changed();
		
		return;
	}
	
	#############################################

	sub share_count {
		my $self	= shift;
		
		return $self->Rails::Objects::Holder::share_count( $self->get_id() );
	}

	#############################################

	sub remove_shares {
		my $self	= shift;
		my $count	= shift;
		
		return $self->Rails::Objects::Holder::remove_shares( $self->get_id(), $count );
	}	
	
	#############################################

	sub counts_towards_limit {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $color = color_of_space( $x, $y );

		if ( $color eq 'y' || $color eq 'o' || $color eq 'b' ) {
			return 0;
		}
		
		return 1;
	}

	#############################################

	sub price_column {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		return $x;
	}		

	#############################################

	sub price_row {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		return $y;
	}		

	#############################################

	sub maximum_shares {
		my $self	= shift;

		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $color = color_of_space( $x, $y );
		
		if ( $color eq 'o' || $color eq 'b' ) {
			return 10;
		}
		
		return 6;
	}

	#############################################

	sub max_in_a_purchase {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $color = color_of_space( $x, $y );
		
		if ( $color eq 'b' ) {
			return 10;
		}
		
		return 1;
	}	

	#############################################
	
	sub move_stock_right {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $new_color = color_of_space( $x + 1, $y );
		
		if ( $new_color ne '' ) {
			$x++;
			$self->set_current_position( $x . ',' . $y );
			$self->set_current_price( value_of_space( $x, $y ) );
			$self->set_current_index( $self->game()->get_market_stamp() );
			$self->changed();
			return 1;
		}
		
		if ( $y == 0 ) {
			return 0;
		}
		
		$y--;
		
		$self->set_current_position( $x . ',' . $y );
		$self->set_current_price( value_of_space( $x, $y ) );
		$self->set_current_index( $self->game()->get_market_stamp() );
		$self->changed();
		return 1;
	}
	
	#############################################

	sub move_stock_left {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $new_color = color_of_space( $x - 1, $y );
		
		if ( $new_color ne '' ) {
			$x--;
			$self->set_current_position( $x . ',' . $y );
			$self->set_current_price( value_of_space( $x, $y ) );
			$self->set_current_index( $self->game()->get_market_stamp() );
			$self->changed();
			return 1;
		}
		
		$new_color = color_of_space( $x, $y + 1 );
		
		if ( $new_color eq '' ) {
			return 0;
		}
		
		$y++;
		
		$self->set_current_position( $x . ',' . $y );
		$self->set_current_price( value_of_space( $x, $y ) );
		$self->set_current_index( $self->game()->get_market_stamp() );
		$self->changed();
		return 1;
	}
	
	#############################################

	sub move_stock_up {
		my $self	= shift;
		
		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		if ( $y == 0 ) {
			return 0;
		}
		
		$y--;
		
		$self->set_current_position( $x . ',' . $y );
		$self->set_current_price( value_of_space( $x, $y ) );
		$self->set_current_index( $self->game()->get_market_stamp() );
		$self->changed();
		return 1;
	}
		
	#############################################

	sub move_stock_down {
		my $self	= shift;

		my ( $x, $y ) = split( /,/, $self->get_current_position() );
		
		my $new_color = color_of_space( $x, $y + 1 );
		
		if ( $new_color eq '' ) {
			return 0;
		}
		
		$y++;
		
		$self->set_current_position( $x . ',' . $y );
		$self->set_current_price( value_of_space( $x, $y ) );
		$self->set_current_index( $self->game()->get_market_stamp() );
		$self->changed();
		return 1;
	}

	#############################################
	#############################################
	
}


	
	

#############################################################################

sub value_of_space {
	my $x		= shift;
	my $y		= shift;
	
	my @squares = (
		[ 60, 67, 71, 76, 82, 90, 100, 112, 126, 142, 160, 180, 200, 225, 250, 275, 300, 325, 350,  -1 ],
		[ 53, 60, 66, 70, 76, 82,  90, 100, 112, 126, 142, 160, 180, 200, 220, 240, 260, 280, 300,  -1 ],
		[ 46, 55, 60, 65, 70, 76,  82,  90, 100, 111, 125, 140, 155, 170, 185, 200,  -1,  -1,  -1 ],
		[ 38, 48, 54, 60, 66, 71,  76,  82,  90, 100, 110, 120, 130,  -1,  -1,  -1 ],
		[ 32, 41, 48, 55, 62, 67,  71,  76,  82,  90, 100,  -1,  -1 ],
		[ 25, 34, 42, 50, 58, 65,  67,  71,  75,  80,  -1 ],
		[ 18, 27, 36, 45, 54, 63,  67,  69,  70,  -1 ],
		[ 10, 20, 30, 40, 50, 60,  67,  68,  -1 ],
		[ -1, 10, 20, 30, 40, 50,  60,  -1 ],
		[ -1, -1, 10, 20, 30, 40,  50,  -1 ],
		[ -1, -1, -1, 10, 20, 30,  40,  -1 ],
		[ -1, -1, -1, -1, -1, -1,  -1,  -1 ],	
	);
	
	if ( $y < 0 || $y >= scalar( @squares ) ) {
		return -1;
	}
	
	my @row = @{ $squares[ $y ] };
	
	if ( $x < 0 || $x >= scalar( @row ) ) {
		return -1;
	}
	
	return $row[ $x ];
}

#############################################################################

sub color_of_space {
	my $x		= shift;
	my $y		= shift;

	my @colors = ( '', 'w', 'o', 'b' );
	
	my @squares = (
		[ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1 ],
		[ 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1 ],
		[ 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1 ],
		[ 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1 ],
		[ 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0,-1,-1 ],
		[ 3, 2, 2, 1, 1, 0, 0, 0, 0, 0,-1 ],
		[ 3, 3, 2, 2, 1, 0, 0, 0, 0,-1 ],
		[ 3, 3, 3, 2, 1, 1, 0, 0,-1 ],
		[-1, 3, 3, 3, 1, 0, 0,-1 ],
		[-1,-1, 3, 3, 3, 1, 0,-1 ],
		[-1,-1,-1, 3, 3, 3, 1,-1 ],
		[-1,-1,-1,-1,-1,-1,-1,-1 ],	
	);
	
	if ( $y < 0 || $y >= scalar( @squares ) ) {
		return '';
	}
	
	my @row = @{ $squares[ $y ] };
	
	if ( $x < 0 || $x >= scalar( @row ) ) {
		return '';
	}
	
	return $colors[ $row[ $x ] ];	
}

#############################################################################
#############################################################################
1
