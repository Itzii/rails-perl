package Rails::Objects::Route;

use strict;
use warnings;


################

{
	use Object::InsideOut;
	
	my @fullmap				:Field	:Default( undef )	:Get(fullmap)		:Arg('map');
	my @nodes				:Field	:Default( undef )	:Get(nodes);
	my @node_values			:Field	:Default( undef )	:Get(node_values);
	my @finished			:Field	:Default( 0 )		:Set(set_finished);
	my @limit				:Field	:Default( -1 )		:Std(limit)			:Arg('limit');
	
	
	#############################################
	
	sub _init	:Init {
		my $self	= shift;
		
		$self->set( \@nodes, [] );
		$self->set( \@node_values, {} );
		
		return;
	}
	
	#############################################
	
	sub paths {
		my $self	= shift;
		
		my @paths = ();
		my $count = 0;
		foreach my $node_index ( 0 .. scalar( @{ $self->nodes() } ) - 2 ) {
			my @local = sort( $self->nodes()->[ $node_index ], $self->nodes()->[ $node_index + 1 ] );
			push( @paths, $local[ 0 ] . '-' . $local[ 1 ] );
			
			if ( $self->node_values()->{ $self->nodes()->[ $node_index + 1 ] } > 0 ) {
				$count++;
			}
		}
		
		return @paths;
	}
	
	#############################################

	sub contains_path {
		my $self	= shift;
		my $path	= shift;
		
		foreach my $local_path ( $self->paths() ) {
			if ( $path eq $local_path ) {
				return 1;
			}
		}
		
		return 0;
	}

	#############################################

	sub get_value {
		my $self	= shift;
	
		my $value = 0;
		my $count = 1;
		foreach my $node ( @{ $self->nodes() } ) {
			$value += $self->node_values()->{ $node };
			
			if ( $value > 0 ) {
				$count++;
			}
		}
		
		return $value;
	}

	#############################################

	sub stop_count {
		my $self	= shift;
		
		my $count = 0;
		foreach my $node ( @{ $self->nodes() } ) {
			if ( $self->node_values()->{ $node } > 0 ) {
				$count++;
			}
		}
		
		return $count;
	}
	
	#############################################

	sub contains_node {
		my $self				= shift;
		my $new_node			= shift;
		my $flag_ignore_first	= shift; # optional 0
		
		unless ( defined( $flag_ignore_first ) ) {
			$flag_ignore_first = 0;
		}
		
		my $count = 0;		
		foreach my $node ( @{ $self->nodes() } ) {
		
			if ( $count == 0 && $flag_ignore_first ) {
				next;
			}
		
			if ( $node eq $new_node ) {
				return 1;
			}
			
			$count++;
		}
		
		return 0;
	}

	#############################################

	sub last_node {
		my $self		= shift;
		
		return $self->nodes()->[ -1 ];
	}
	
	#############################################
	
	sub previous_node {
		my $self		= shift;
		
		if ( scalar( @{ $self->nodes() } ) <= 1 ) {
			return '';
		}
		
		return $self->nodes()->[ -2 ];
	}	

	#############################################

	sub finish {
		my $self		= shift;
		
		$self->set_finished( 1 );
		
		return;		
	}

	#############################################

	sub get_finished {
		my $self		= shift;
		
		if ( $self->stop_count() >= $self->get_limit() && $self->get_limit() > -1 ) {
			return 1;
		}
		
		if ( $finished[ $$self ] == 1 ) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub add_node {
		my $self		= shift;
		my $node		= shift;
		my $value		= shift;
				
		push( @{ $self->nodes() }, $node );
		$self->node_values()->{ $node } = $value;
			
		return;
	}		

	#############################################

	sub copy_from {
		my $self	= shift;
		my $other	= shift;
		
		foreach my $node ( @{ $other->nodes() } ) {
			$self->add_node( $node, $other->node_values()->{ $node } );
		}
		
		$self->set_finished( $other->get_finished() );
		$self->set_limit( $other->get_limit() );
		
		return;
	}

	#############################################

	sub contains_common_path {
		my $self	= shift;
		my $other	= shift;
		
		unless ( defined( $other ) ) {
			return 0;
		}
	
		foreach my $path ( $self->paths() ) {
			if ( $other->contains_path( $path ) == 1 ) {
				return 1;
			}
		}
		
		return 0;
	}

	#############################################

	sub contains_common_node {
		my $self				= shift;
		my $other				= shift; 
		my $flag_ignore_first	= shift; # optional 0
		
		unless ( defined( $other ) ) {
			return 0;
		}
		
		unless ( defined( $flag_ignore_first ) ) {
			$flag_ignore_first = 0;
		}
	
		my $count = 0;	
		foreach my $node ( $self->nodes() ) {
		
			if ( $count == 0 && $flag_ignore_first ) {
				next;
			}
			
			if ( $other->contains_node( $node, $flag_ignore_first ) == 1 ) {
				return 1;
			}
			
			$count++;
		}
		
		return 0;
	}

	#############################################

	sub as_text {
		my $self		= shift;
	
#		my @paths = $self->paths();
		
		my $text = $self->get_limit() . ' ';
		
		foreach my $node ( @{ $self->nodes() } ) {
			$text .= '(' . $node . ':' . $self->node_values()->{ $node } . ') .. ';
			
#			if ( @paths ) {
#				my $path = shift( @paths );
#				$text .= ' .. ' . $path . ' .. ';
#			}
		}
		
		return $text . ' [' . $self->get_value() . ']{' . $self->stop_count() . '}';		
	}

	#############################################

	sub join_route {
		my $self		= shift;
		my $new_route	= shift;
		
		$self->finish();
		
		my @new_nodes = @{ $new_route->nodes() };
		
		if ( $self->contains_node( $new_nodes[ 0 ] ) ) {
			shift( @new_nodes );
		}
		
		foreach my $node ( @new_nodes ) {
			$self->add_node( $node, $new_route->node_values()->{ $node } );
		}
		
		return;
	}		
		
	#############################################

	sub sub_route {
		my $self		= shift;
		my $start_index	= shift;
		
		my $sub_route = Rails::Objects::Route->new( 'map' => $self->fullmap(), 'limit' => $self->get_limit() );
		
		my $count = -1;
		
		foreach my $node ( @{ $self->nodes() } ) {
		
			my $value = $self->node_values()->{ $node }; 
		
			if ( $value > 0 ) {
				$count++;
			}
			
			if ( $count < $start_index ) {
				next;
			}
			
			$sub_route->add_node( $node, $value );
			
			if ( $count + 1 == $start_index + $self->get_limit() ) {
				last;			
			}
		}
		
		return $sub_route;
	}	
	
	#############################################
	#############################################
	
}


#############################################################################


#############################################################################
#############################################################################
1