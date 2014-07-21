package Rails::Screens::Market;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Screens::Base );
	
	#############################################

	sub _pre_init :PreInit {
		my ( $self, $args ) = @_;
		
		$args->{'type'} = 'market';
		
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

		if ( $common ne '' ) {
			return $common;
		}
		
		if ( $self->action() eq '' ) {
			return $self->show_market_screen();
		}
		
		return $self->show_error( 'Unknown Action Specified' );
	}
		
	#############################################

	sub show_market_screen {
		my $self	= shift;
		
		if ( $self->load_game() == 0 ) {
			return;
		}
		
		my @lines = ();
		
		$self->set_values( 'bank' => $self->game()->get_cash() );

		$self->_stock_prices();
		$self->_par_values();
		$self->_stock_pool();
		$self->_bank_pool();
		$self->_trains();
		
		return $self->body();
	}	

	#############################################

	sub _stock_prices {
		my $self		= shift;
		
		my $margin_x = 320;
		my $margin_y = 105;
		
		my $width = 63;
		my $height = 76;
		
		my @lines = ();
		
		foreach my $corp_key ( $self->game()->corp_keys() ) {
		
			my ( $share_x, $share_y ) = split( /,/, $self->game()->corps()->{ $corp_key }->get_current_position() );
			
			if ( $share_x == -1 || $share_y == -1 ) {
				next;
			}
			
			my $z = $self->game()->corps()->{ $corp_key }->get_current_index();
			
			my $x = $margin_x + $width * $share_x;
			my $y = $margin_y + $height * $share_y;
			
			$y += $self->game()->corps()->{ $corp_key }->get_current_index() * 7;
			
			my %info = (
				'l_key'			=> $corp_key,
				'l_top'			=> $y,
				'l_left'		=> $x,
				'l_position'	=> $z,
			);
			
			push( @lines, \%info );
		}
		
		$self->set_values( 'stock_prices', \@lines );
		
		return;
	}

	#############################################

	sub _par_values {
		my $self		= shift;
	
		my $margin_x = 1545;
		my $margin_y = 100;
		
		my $width = 59;
		my $full_height = 190;

		my %pars = (
			'67'	=> { 'index' => 0, 'list' => [] },
			'71'	=> { 'index' => 1, 'list' => [] },
			'76'	=> { 'index' => 2, 'list' => [] },
			'82'	=> { 'index' => 3, 'list' => [] },
			'90'	=> { 'index' => 4, 'list' => [] },
			'100'	=> { 'index' => 5, 'list' => [] },
		);
		
		foreach my $corp_key ( sort( $self->game()->corp_keys() ) ) {
			my $par = $self->game()->corps()->{ $corp_key }->get_par_price();
			
			unless ( defined( $pars{ $par } ) ) {
				next;
			}
			
			push( @{ $pars{ $par }->{'list'} }, $corp_key );
		}
		
		my @lines = ();
		
		foreach my $par ( keys( %pars ) ) {
			
			my $x = $margin_x + $width * $pars{ $par }->{'index'};
			
			my $index = 1;
			my $height = $full_height / ( scalar( @{ $pars{ $par }->{'list'} } ) + 1 );
			foreach my $corp_key ( @{ $pars{ $par }->{'list'} } ) {
				
				my $y = $margin_y + $height * $index - ( $height / 2 );
				
				my %info = (
					'l_key'			=> $corp_key,
					'l_top'			=> $y,
					'l_left'		=> $x,
					'l_position'	=> $index,
				);
			
				push( @lines, \%info );
				
				$index++;
			}
		}
		
		$self->set_values( 'par_values', \@lines );
		
		return;
	}

	#############################################

	sub _stock_pool {
		my $self		= shift;

		my $margin_x	= 30;
		my $margin_y	= 950;
		my $width		= 280;
		my $height		= 100;
		
		my $stock_index = 0;
		
		my @lines = ();

		foreach my $corp_key ( $self->game()->corp_keys() ) {

			my $count = $self->game()->corps()->{ $corp_key }->share_count();

			if ( $count == 0 ) {
				next;
			}

			my $unfloated = ( $count == 10 ) ? 1 : 0;

			if ( $unfloated == 1 ) {
				$count = 9;
			}

			foreach my $index ( 0 .. $count - 1 ) {

				my $x = $margin_x + $stock_index * $width + ( $index * 8 );
				my $y = $margin_y + $index * 8;
				
				my %info = (
					'l_key'			=> $corp_key,
					'l_top'			=> $y,
					'l_left'		=> $x,
					'l_position'	=> $index,
					'l_pres'		=> ( $unfloated == 1 && $index == $count - 1 ) ? 1 : 0,
				);
				
				push( @lines, \%info );
			}

			$stock_index++;
		}
		
		$self->set_values( 'stock_pool', \@lines );
		
		return;
	}
	
	#############################################

	sub _bank_pool {
		my $self		= shift;
		
		my $margin_x	= 1200;
		my $margin_y	= 480;
		my $width		= 225;
		my $height		= 100;
		
		my @lines = ();

		my $stock_index = 0;

		foreach my $corp_key ( $self->game()->share_keys() ) {

			my $count = $self->game()->share_count( $corp_key );

			if ( $count == 0 ) {
				next;
			}

			foreach my $index ( 0 .. $count - 1 ) {

				my $x = $margin_x + int( $stock_index / 4 ) * $width + ( $index * 8 );
				my $y = $margin_y + ( $stock_index % 4 ) * $height + $index * 8;

				my %info = (
					'l_key'			=> $corp_key,
					'l_top'			=> $y,
					'l_left'		=> $x,
					'l_position'	=> $index,
				);
				
				push( @lines, \%info );
			}

			$stock_index++;
		}
		
		$self->set_values( 'bank_pool_stock', \@lines );

		
		my @train_ids = split( /,/, $self->game()->trains() );
		
		my $full_height = 340;
		my $div_height = $full_height / ( scalar( @train_ids ) + 1 );
		my $index = 0;
		my @train_lines = ();
		foreach my $train ( @train_ids ) {
		
			my $y = $margin_y + $div_height * $index;
			my $x = $margin_x + 2 * $width + 10 + 3 * $index;

			my %info = (
				'l_key'			=> $train,
				'l_top'			=> $y,
				'l_left'		=> $x,
				'l_position'	=> $index,
			);

			push( @train_lines, \%info );
			$index++;	
		}
		
		$self->set_values( 'bank_pool_trains', \@train_lines );
		
		return;
	}
		
	#############################################

	sub _trains {
		my $self		= shift;
		
		my @trains = @{ $self->game()->new_trains() };
		
		my $margin_x	= 1970;
		my $margin_y	= 100;
		my $width		= 225;
		my $height		= 130;
		
		my $index = 0;

		my @lines = ();

		foreach my $train ( @trains ) {
		
			my $y = $margin_y + $index * $height;
			my $x = $margin_x;
			
			my %info = (
				'l_key'			=> $train,
				'l_top'			=> $y,
				'l_left'		=> $x,
				'l_position'	=> $index,
			);
			
			push( @lines, \%info );
			
			$index++;		
		}
		
		$self->set_values( 'trains' => \@lines );
		
		return;
	}

	#############################################
	#############################################
}

#############################################################################
#############################################################################
1
