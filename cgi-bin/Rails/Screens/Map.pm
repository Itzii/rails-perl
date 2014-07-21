package Rails::Screens::Map;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Screens::Base );

	#############################################

	sub _pre_init :PreInit {
		my ( $self, $args ) = @_;
		
		$args->{'type'} = 'map';
		
		return;     
	}

	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		return;
	}

	#############################################

	sub process_action {
		my $self	= shift;
		
		my $common = $self->Rails::Screens::Base::process_action();
		
#		print STDERR $common;
		
		if ( $common ne '' ) {
			return $common;
		}
		
		if ( $self->action() eq '' ) {
			return $self->show_map_screen();
		}
		
		return $self->show_error( 'Unknown Action Specified' );
	}
		
	#############################################

	sub show_map_screen {
		my $self	= shift;
		
		if ( $self->load_game() == 0 ) {
			return $self->show_error( 'Invalid Game ID' );
		}
		
		$self->_hexes();
		$self->_round();
		
		if ( $self->game()->get_current_round() == 0 ) {
			$self->_stock();
		}
		else {
			$self->_operating();
		}
			
		return $self->body();
	}	

	#############################################

	sub _hexes {
		my $self		= shift;
		
		my $width = 111;
		my $height = 95;

		my $left_margin = 78;
		my $top_margin = -17;

		my $y = $top_margin;

		my @lines = ();
		
		foreach my $letter ( 'A', 'C', 'E', 'G', 'I', 'K' ) {

			my $x = $left_margin;
		
			foreach my $number ( 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23 ) {
				my %info = $self->div( $letter, $number, $x, $y );
				if ( $info{'tid'} ne '' ) {
					push( @lines, \%info );
				}
				$x += $width - 1;	
			}
		
			$y += $height * 2;
		}

		$y = $top_margin + $height;

		foreach my $letter ( 'B', 'D', 'F', 'H', 'J' ) {

			my $x = $left_margin + $width / 2;

			foreach my $number ( 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24 ) {
				my %info = $self->div( $letter, $number, $x, $y );
				if ( $info{'tid'} ne '' ) {
					push( @lines, \%info );
				}
				$x += $width - 1;	
			}
		
			$y += $height * 2;	
		}
		
		$self->set_values( 'hexes', \@lines );
	}
	
	#############################################

	sub div {
		my $self		= shift;
		my $letter		= shift;
		my $number		= shift;
		my $x			= shift;
		my $y			= shift;
		
		my $space_id = $letter . $number;
		
		my $space = $self->game()->map()->space( $space_id );
			
		unless ( defined( $space ) ) {
			return ( 'tid' => '' );
		}
		
		my $tile = $self->game()->map()->tile( $space_id );
		
		unless ( defined( $tile ) ) {
			return ( 'tid' => '' );
		}

		if ( $tile->get_id() eq '0' ) {
			return ( 'tid' => '' );
		}

		if ( $tile->get_count() < 1 ) {
			return ( 'tid' => '' );
		}
		
		return (
			'tid'			=> $tile->get_id(),
			'ttop'			=> $y,
			'tleft'			=> $x,
			'twidth'		=> 122,
			'trotation'		=> 60 * ( 5 - $space->get_orientation() ) + 30,
			'trotation2'	=> $space->get_orientation(),
		);
	}
	
	#############################################

	sub _round {
		my $self		= shift;
		
		my $phase	= $self->game()->get_current_phase();
		my $round	= $self->game()->get_current_round();

		if ( $phase > 7 ) {
			return '';
		}
		
		$phase -= 2;
		
		if ( $phase < 0 ) {
			$phase = 0;
		}

		my $left_margin = 1248;
		my $top_margin = 653;

		$self->set_values( 
			'stop'	=> $top_margin + $round * 60, 
			'sleft'	=> $left_margin + $phase * 52,
		);
		
		return;
	}

	#############################################

	sub _stock {
		my $self		= shift;
		
		my $left_margin = 1550;
		my $top_margin = 100;
		my $width = 350;
		
		my $height = 1100 / ( $self->game()->number_of_players() + 1 );
		
		my @lines = ();

		my $count = 0;
		
		foreach my $pid ( $self->game()->all_player_ids() ) {
			my $x = $left_margin;
			my $y = $top_margin + $height * $count;
			
			my %info = (
				'ltop'		=> $y,
				'lleft'		=> $x,
				'lwidth'	=> $width,
				'l_name'	=> $self->game()->players()->[ $pid ]->display_name(),
				'l_current'	=> ( $self->game()->get_current_player() == $pid ) ? 1 : 0,
			);
			
			push( @lines, \%info );
			$count++;
		}

		$self->set_values( 'show_stock' => 1 );
		$self->set_values( 'stock' => \@lines );
		
		return;
	}

	#############################################

	sub _operating {
		my $self		= shift;
		
		
	

		return '';
	}


	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
