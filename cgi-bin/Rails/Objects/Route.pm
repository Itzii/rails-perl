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
	
	my @finished_right		:Field	:Default( 0 )		:Std(finished_right);
	my @limit_right			:Field	:Default( -1 )		:Std(limit_right)	:Arg('limit_right');
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
		my $self		= shift;
		my $new_node	= shift;
		
		foreach my $node ( @{ $self->nodes() } ) {
			if ( $node eq $new_node ) {
				return 1;
			}
		}
		
		return 0;
	}

	#############################################

	sub last_node {
		my $self		= shift;
		
		if ( $self->going_left() == 1 ) {
			return $self->nodes()->[ 0 ];
		}
		
		return $self->nodes()->[ -1 ];
	}
	
	#############################################
	
	sub previous_node {
		my $self		= shift;
		
		if ( scalar( @{ $self->nodes() } ) <= 1 ) {
			return '';
		}
		
		if ( $self->going_left() == 1 ) {
			return $self->nodes()->[ 1 ];
		}
		
		return $self->nodes()->[ -2 ];
	}	

	#############################################

	sub going_left {
		my $self		= shift;
		
		if ( $self->get_finished_right() == 1 ) {
			return 1;
		}
		
		if ( 
			$self->stop_count() >= $self->get_limit_right() 
			&& $self->get_limit_right() > -1 
		) {
			return 1;
		}
		
		return 0;
	}

	#############################################

	sub finish_end {
		my $self		= shift;
		
		if ( $self->going_left() == 0 ) {
			$self->set_finished_right( 1 );
		}
		else {
			$self->set_finished( 1 );
		}
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
				
		if ( $self->going_left() == 1 ) {
			unshift( @{ $self->nodes() }, $node );
		}
		else {
			push( @{ $self->nodes() }, $node );
		}
		
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
		
		$self->set_finished_right( $other->get_finished_right() );
		$self->set_limit_right( $other->get_limit_right() );
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

	sub as_text {
		my $self		= shift;
	
#		my @paths = $self->paths();
		
		my $text = '';
		
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
	#############################################
	
}


#############################################################################


#############################################################################
#############################################################################
1