package Rails::Objects::Player;

use strict;
use warnings;


################

{
	use Object::InsideOut qw( Rails::Objects::Holder );
	
	my @long_name			:Field	:Default( '' )		:Get(get_long_name);
	my @running				:Field	:Default( '' )		:Get(get_running);
	my @pass_flag			:Field	:Default( 0 )		:Get(get_pass_flag);
	my @sold_this_round		:Field	:Default( '' );
	my @bought_this_round	:Field	:Default( '' );
	
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set_doctype( 'Player' );
		$self->set( \@running, {} );
		$self->set( \@pass_flag, 0 );
		
		return;
	}
	
	#############################################

	sub clear {
		my $self 	= shift;

		$self->set( \@long_name, '' );
		$self->set( \@running, {} );
		$self->set( \@pass_flag, 0 );

		$self->Rails::Objects::Holder::clear();
		
		return;
	}

	#############################################

	sub create_state {
		my $self		= shift;
		my $game_id		= shift;
		
		$self->connection()->sql( 
			"INSERT INTO state_players ( game_id, player_id, long_name, cash, 
			shares, privates, running, pass_flag, sold, bought )
			VALUES ( ?, ?, '', ?, '', '', '', 0, '', '' )",
			$game_id, $self->get_id(), $self->get_cash(),
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
			"UPDATE state_players SET
			long_name=?, cash=?, shares=?, 
			privates=?, running=?,
			pass_flag=?, sold=?, bought=?
			WHERE game_id=? AND player_id=?",
			$self->get_long_name(), $self->get_cash(), $self->shares_text(), 
			$self->privates_text(), join( ',', keys( %{ $self->get_running() } ) ),
			$self->get_pass_flag(),
			$sold_this_round[ $$self ], $bought_this_round[ $$self ],
			$self->game()->get_id(), $self->get_id(),
		);
		
		$self->clear_flags();
				
		return;
	}
		


	#############################################

	sub load_state {
		my $self		= shift;
		my $game_id		= shift;
		
		my @records = $self->connection()->sql( 
			"SELECT * FROM state_players WHERE game_id=? AND player_id=?",
			$game_id, $self->get_id(),
		);
		
		unless ( @records ) {
			return 0;
		}
		
		$self->set_long_name( $records[ 0 ]->{'long_name'} );
		
		$self->set_cash( $records[ 0 ]->{'cash'} );

		$self->set_pass_flag( $records[ 0 ]->{'pass_flag'} );
		
		foreach my $ceo ( split( /,/, $records[ 0 ]->{'running'} ) ) {
			$self->set_running()->{ $ceo } = 1;
		}
		
		$self->privates_from_text( $records[ 0 ]->{'privates'} );
		$self->shares_from_text( $records[ 0 ]->{'shares'} );
		
		$self->set( \@sold_this_round, $records[ 0 ]->{'sold'} );
		$self->set( \@bought_this_round, $records[ 0 ]->{'bought'} );
		
		$self->clear_changed();

		return 1;
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

	sub set_running {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@running, $value );
		$self->changed();
		
		return;
	}

	#############################################

	sub set_pass_flag {
		my $self		= shift;
		my $value		= shift;
		
		$self->set( \@pass_flag, $value );
		$self->changed();
		
		return;
	}
	
	#############################################

	sub display_name {
		my $self	= shift;
		
		
		if ( $self->get_long_name() ne '' ) {
			return $self->get_long_name();
		}
		
		return 'Player ' . ( $self->get_id() + 1 );
	}		

	#############################################

	sub is_ceo_of {
		my $self	= shift;
		my $corp	= shift;
		
		if ( defined ( $self->get_running()->{ $corp } ) ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub make_ceo_of {
		my $self	= shift;
		my $corp	= shift;
		
		$self->get_running()->{ $corp } = 1;
		
		$self->changed();
		
		return;
	}

	#############################################

	sub remove_as_ceo {
		my $self	= shift;
		my $corp	= shift;
		
		delete( $self->get_running()->{ $corp } );
	
		$self->changed();
	
		return;
	}

	
	#############################################

	sub did_buy_this_round {
		my $self	= shift;
		my $corp	= shift;
		
		my %all_bought = map { $_ => 1 } split( /,/, $bought_this_round[ $$self ] );
		
		if ( exists( $all_bought{ $corp } ) ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub did_sell_this_round {
		my $self	= shift;
		my $corp	= shift;
		
		my %all_sold = map { $_ => 1 } split( /,/, $sold_this_round[ $$self ] );
		
		if ( exists( $all_sold{ $corp } ) ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub add_to_sold_this_round {
		my $self	= shift;
		my $corp	= shift;
		
		my %all_sold = map { $_ => 1 } split( /,/, $sold_this_round[ $$self ] );
		
		$all_sold{ $corp } = 1;
		my @corp_keys = keys( %all_sold );
		
		$self->set( \@sold_this_round, join( ',', @corp_keys ) );
		
		return;
	}
	
	#############################################

	sub add_to_bought_this_round {
		my $self	= shift;
		my $corp	= shift;
		
		my %all_bought = map { $_ => 1 } split( /,/, $bought_this_round[ $$self ] );
		
		$all_bought{ $corp } = 1;
		my @corp_keys = keys( %all_bought );
		
		$self->set( \@bought_this_round, join( ',', @corp_keys ) );
		
		return;
	}

	#############################################

	sub clear_bought_sold {
		my $self	= shift;
		
		$self->set( \@sold_this_round, '' );
		$self->set( \@bought_this_round, '' );
		
		return;
	}

	#############################################

	sub did_buy_or_sell {
		my $self	= shift;
		
		if ( $sold_this_round[ $$self ] ne '' ) {
			return 1;
		}
		
		if ( $bought_this_round[ $$self ] ne '' ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub total_certificate_count { # TODO test now
		my $self	= shift;
		
		my $count = 0;

		foreach my $corp ( $self->share_keys() ) {
		
			if ( $self->game()->corps()->{ $corp }->counts_towards_limit() == 1 ) {
		
				$count += $self->share_count( $corp );
			
				if ( $self->is_ceo_of( $corp ) ) {
					$count--;
				}
			}
		}
		
		return $count;
	}

	#############################################

	

	#############################################
	#############################################
	
}


#############################################################################





#############################################################################
#############################################################################
1