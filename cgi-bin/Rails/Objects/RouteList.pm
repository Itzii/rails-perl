package Rails::Objects::RouteList;

use strict;
use warnings;

use overload 
	"+" => "add_list",
	;


################

{
	use Object::InsideOut;
	use Rails::Objects::Route;
	
	my @fullmap		:Field	:Default( undef )	:Get(fullmap)	:Arg('map');
	my @routes		:Field	:Default( undef )	:Get(routes);
	my @corp		:Field	:Default( '' )		:Std(corp)		:Arg('corp');
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set( \@routes, [] );
		
		return;
	}
	
	#############################################

	sub add_route {
		my $self	= shift;
		my $route	= shift;
		
		push( @{ $routes[ $$self ] }, $route );
				
		return;
	}

	#############################################

	sub routes_total {
		my $self	= shift;
		
		my $total = 0;
		foreach my $route ( @{ $routes[ $$self ] } ) {
			$total += $route->get_value();
		}
		
		return $total;
	}

	#############################################

	sub best_not_matching {
		my $self	= shift;
		my $other	= shift;
		
		foreach my $route ( @{ $routes[ $$self ] } ) {
			if ( $route->contains_common_path( $other ) == 0 ) {
				return $route;
			}
		}
		
		return undef;
	}
	
	#############################################

	sub add_list {
		my $self		= shift;
		my $other_list	= shift;
		
		foreach my $route ( @{ $other_list->routes() } ) {
			$self->add_route( $route );
		}
		
		return;
	}

	#############################################

	sub generate_from_node {
		my $self		= shift;
		my $node		= shift;
		my $limit		= shift;
		
		my $high_low = ( $self->fullmap()->game()->get_current_phase() >= 5 ) ? 1 : 0;
		
		my $route = Rails::Objects::Route->new( 'map' => $self->fullmap(), 'limit' => $limit );
		$route->add_node( $node, $self->fullmap()->value_of_node( $node, $high_low ) );
		
		$self->add_route( $route );
		
		if ( $limit > 2 ) {
			my $new_route = Rails::Objects::Route->new( 'map' => $self->fullmap(), 'limit' => $limit, 'limit_right' => 2 );
			$new_route->add_node( $node, $self->fullmap()->value_of_node( $node, $high_low ) );
			$self->add_route( $new_route );
		}
		
		if ( $limit > 4 ) {
			my $new_route = Rails::Objects::Route->new( 'map' => $self->fullmap(), 'limit' => $limit, 'limit_right' => 3 );
			$new_route->add_node( $node, $self->fullmap()->value_of_node( $node, $high_low ) );
			$self->add_route( $new_route );
		}
		
		$self->extend_routes();
		
		my @final = ();
		
		foreach my $t_route ( @{ $self->routes() } ) {
		
			my $dup_flag = 0;
		
			foreach my $t_final ( @final ) {
				if ( @{ $t_final->nodes() } ~~ reverse( @{ $t_route->nodes() } ) ) {
					$dup_flag = 1;
					last;
				}

				if ( @{ $t_final->nodes() } ~~ @{ $t_route->nodes() } ) {
					$dup_flag = 1;
					last;
				}
			}
			
			if ( $dup_flag == 0 ) {
				push( @final, $t_route );
			}		
		}
		
		@{ $self->routes() } = @final;
		
		$self->sort_routes();
		
		return;
	}

	#############################################

	sub extend_routes {
		my $self		= shift;
		
		my $finished = 0;
		
		while ( $finished == 0 ) {
		
			foreach my $route ( @{ $self->routes() } ) {
				$finished = 1;
				
				if ( $route->get_finished() == 0 ) {
					$self->extend_single_route( $route );				
					$finished = 0;
				}
			}		
		}		
		
		return;
	}

	#############################################

	sub extend_single_route {
		my $self		= shift;
		my $route		= shift;
		
		my $excluded_space = '';
		my ( $current_space, $current_node ) = split( /\./, $route->last_node() );
		my ( $last_space, $last_node ) = split( /\./, $route->previous_node() );
		
		if ( defined( $last_space ) && defined( $current_space ) ) {
			if ( $last_space eq $current_space && $current_node =~ m{ ^ side }xms ) {
				$excluded_space = $current_space;
			}		
		}
		
		my @new_spurs = ();
		my @all_spurs = $self->fullmap()->node_connects_to( $route->last_node() );
		
		foreach my $spur ( @all_spurs ) {
			
			my ( $spur_space, $spur_node ) = split( /\./, $spur );
			
			if ( 
				$spur_space ne $excluded_space 
				&& $route->contains_node( $spur ) == 0
			) {
				push( @new_spurs, $spur );
			}
		}
		
		unless ( @new_spurs ) {
			$route->finish_end();
			return;
		}
		
		my $spur = shift( @new_spurs );
		
		foreach my $split_spur ( @new_spurs ) {
			
			my $new_route = Rails::Objects::Route->new( 'map' => $self->fullmap() );
			$new_route->copy_from( $route );

			$self->add_node_to_route( $new_route, $split_spur );
			$self->add_route( $new_route );
		}
		
		$self->add_node_to_route( $route, $spur );
		
		return;		
	}	
		
	#############################################

	sub add_node_to_route {
		my $self		= shift;
		my $route		= shift;
		my $node		= shift;
		
		if ( $node =~ m{ \+ }xms ) {
			my ( $junk, $ob_location ) = split( /\./, $node );
			
			$route->add_node( $ob_location, $self->fullmap()->value_of_node( $node, $self->fullmap()->high_low() ) );
			$route->finish_end();
		}
		else {
		
			$route->add_node( $node, $self->fullmap()->value_of_node( $node, $self->fullmap()->high_low() ) );
			
			if ( $self->fullmap()->can_corp_trace_through_node( $node, $self->get_corp() ) == 0 ) {
				$route->finish_end();
			}
		}
		
		return;		
	}

	#############################################

	sub sort_routes {
		my $self		= shift;
		
		@{ $routes[ $$self ] } = sort {
		
			$b->get_value() <=> $a->get_value()
		
		} @{ $routes[ $$self ] };
	
		return;
	}
	
		

	#############################################
	#############################################
	
}


#############################################################################


#############################################################################
#############################################################################
1	
	
	
