package Rails::Objects::Holder;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Base::Objects::Base );
	
	my @game		:Field			:Default( undef )	:Get(game)		:Arg( 'Name' => 'game', 'Mandatory' => 1 );
	my @cash		:Field			:Default( 0 )		:Std(cash);
	my @privates	:Field			:Default( undef )	:Get(privates);
	my @shares		:Field			:Default( undef )	:Get(shares);
	my @trains		:Field			:Default( undef)	:Get(trains);

	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set_doctype( 'Holder' );
		
		$self->set( \@cash, 0 );
		$self->set( \@shares, {} );
		$self->set( \@privates, {} );
		$self->set( \@trains, [] );
		
		return;
	}
	
	#############################################

	sub clear {
		my $self 	= shift;

		$self->set( \@cash, 0 );
		$self->set( \@shares, {} );
		$self->set( \@privates, {} );
		$self->set( \@trains, [] );

		$self->Rails::Objects::Base::clear();
		
		return;
	}

	#############################################

	sub adjust_cash {
		my $self	= shift;
		my $amount	= shift;
		
		if ( $amount == 0 ) {
			return $self->get_cash();
		}
		
		$self->set_cash( $self->get_cash() + $amount );
		
		if ( $self->get_cash() < 0.00 ) {
			$self->set_cash( 0.00 );
		}
		
		$self->changed();
		
		return $self->get_cash();
	}

	#############################################

	sub add_private {
		my $self		= shift;
		my @privates	= @_;
		
		foreach ( @privates ) {
			$self->privates()->{ $_ } = 1;
		}
		
		$self->changed();
		
		return;
	}

	#############################################

	sub remove_private {
		my $self	= shift;
		my $private	= shift;
		
		delete ( $self->privates()->{ $private } );
		
		$self->changed();

		return;
	}
	
	#############################################

	sub holds_private {
		my $self	= shift;
		my $private	= shift;
		
		if ( defined( $self->privates()->{ $private } ) ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub private_keys {
		my $self	= shift;
		
		return sort( keys( %{ $self->privates() } ) );
	}

	#############################################

	sub privates_text {
		my $self	= shift;
		
		return join( ',', sort( keys( %{ $self->privates() } ) ) );
	}

	#############################################

	sub privates_from_text {
		my $self	= shift;
		my $text	= shift;
		
		$self->set( \@privates, {} );
		
		foreach my $private ( split( /,/, $text ) ) {
			$self->privates()->{ $private } = 1;
		}
		
		$self->changed();
		
		return;
	}

	#############################################

	sub share_keys {
		my $self	= shift;
		
		return sort( keys( %{ $self->shares() } ) );
	}

	#############################################

	sub holds_share {
		my $self	= shift;
		my $corp	= shift;
		
		return ( $self->share_count( $corp ) > 0 ) ? 1 : 0;
	}

	#############################################

	sub share_count {
		my $self	= shift;
		my $corp	= shift;
		
		if ( defined( $self->shares()->{ $corp } ) ) {
			return $self->shares()->{ $corp };
		}
		
		return 0;
	}

	#############################################

	sub add_shares {
		my $self	= shift;
		my $corp	= shift;
		my $count	= shift;
		
		my $current_count = $self->share_count( $corp );
		
		$current_count += $count;

		$self->shares()->{ $corp } = $current_count;
		
		$self->changed();
		
		return;
	}
		
	#############################################

	sub remove_shares {
		my $self	= shift;
		my $corp	= shift;
		my $count	= shift;
		
		my $current_count = $self->share_count( $corp );
		
		if ( $current_count <= $count ) {
			$current_count = 0;
			delete( $self->shares()->{ $corp } );
		}
		else {
			$current_count -= $count;
			$self->shares()->{ $corp } = $current_count;
		}
		
		$self->changed();

		return $current_count;
	}
		
	#############################################

	sub shares_text {
		my $self	= shift;
		
		my @share_info;		
		foreach my $corp ( sort( keys( %{ $self->shares() } ) ) ) {
			push( @share_info, $corp . ',' . $self->shares()->{ $corp } );
		}
		
		return join( ';', @share_info );
	}
		
	#############################################

	sub shares_from_text {
		my $self		= shift;
		my $text		= shift;
		
		$self->set( \@shares, {} );

		foreach my $corp ( split( /;/, $text ) ) {
			my @parts = split( /,/, $corp );

			$self->shares()->{ $parts[ 0 ] } = $parts[ 1 ];
		}
		
		$self->changed();
		
		return;
	}

	#############################################

	sub train_count {
		my $self	= shift;
		
		return scalar( @{ $self->trains() } );
	}		

	#############################################

	sub add_train {
		my $self	= shift;
		my @train	= @_;
		
		my @current = @{ $self->trains() };
		
		foreach ( @train ) {
			push( @current, $_ );
		}
		
		$self->set( \@trains, \@current );
		
		$self->changed();
		
		return;		
	}
	
	#############################################

	sub remove_train {
		my $self	= shift;
		my $train	= shift;
		
		my $removed = $self->remove_train_type( $train );
		
		$removed--;
		
		if ( $removed > 0 ) {
			foreach ( 1 .. $removed ) {
				$self->add_train( $train );
			}
		}
		
		$self->changed();
		
		return;
	}

	#############################################
	
	sub remove_train_type {
		my $self	= shift;
		my $train	= shift;
		
		my @current = @{ $self->trains() };
		my @new = ();
		
		my $count = 0;
		
		foreach my $t ( @current ) {
			if ( $t eq $train ) {
				$count++;
			}
			else {
				push( @new, $t );
			}
		}
		
		$self->set( \@trains, \@new );
		
		if ( $count > 0 ) {
			$self->changed();
		}
		
		return $count;
	}	
		
	#############################################

	sub trains_text {
		my $self	= shift;
		
		return join( ',', sort( @{ $self->trains() } ) );
		
	}
	
	#############################################

	sub trains_from_text {
		my $self	= shift;
		my $text	= shift;
		
		my @t_trains = @{ $self->trains() };
		
		push( @t_trains, split( /,/, $text ) );
		
		$self->set( \@trains, \@t_trains );
		
		return;
	}
	
	#############################################

	

	#############################################
	#############################################
	
}


#############################################################################





#############################################################################
#############################################################################
1	
