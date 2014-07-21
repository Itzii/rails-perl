package Base::Objects::Base_List;

use strict;
use warnings;


###################
{
    use Object::InsideOut;
    use Base::Objects::Base;
	use Scalar::Util qw( looks_like_number refaddr );

    my @connection      :Field  :Default( undef )	:Get(connection)    :Arg(connection);

    my @changed         :Field  :Default( 0 )		:Get(has_changed);
    my @doctype         :Field  :Default( '' )		:Arg(doctype);
    my @ref_items       :Field;
    my @sortdescending  :Field  :Default( 0 )   	:Std(sort_descending);

    #############################################

	sub _init :Init {
		my $self		= shift;

		$self->set( \@ref_items, [] );
		
		return;
	}
	
    #############################################

	sub count {
		my $self		= shift;
		
		return scalar( @{ $ref_items[ $$self ] } );
	}
	
	#############################################
	
	sub items {
		my $self		= shift;
		
		return @{ $ref_items[ $$self ] };
	}
	
	#############################################
	
	sub r_items {
		my $self		= shift;
		
		return $ref_items[ $$self ];
	}
	
	#############################################
	
	sub item {
		my $self		= shift;
		my $index		= shift;
		
		if ( $index < 0 || $index >= $self->count() ) {
			return undef;
		}
		
		return $ref_items[ $$self ]->[ $index ];
	}

    #############################################

    sub changed {
        my $self        = shift;

		$self->set( \@changed, 1 );

        return;
    }

    #############################################

    sub clear_changed {
        my $self        = shift;

		$self->set( \@changed, 0 );

        return;
    }

    #############################################

    sub clear_flags {
        my $self        = shift;

        $self->clear_changed();

        return;
    }

    #############################################

    sub clear {
        my $self        = shift;

		$self->set( \@ref_items, [] );
		
        $self->changed();

        return;
    }
	
    #############################################

	sub empty {
		my $self		= shift;

		
		$self->set( \@ref_items, [] );
		
		$self->changed();
		
		return;
	}

    #############################################

    sub add {
        my $self        = shift;
        my @new_items   = @_;

        foreach my $item ( @new_items ) {
			push( @{ $ref_items[ $$self ]}, $item );
        }

        $self->changed();

        return;
    }

    #############################################

    sub insert {
        my $self        = shift;
        my $index       = shift;
        my $new_item    = shift;

        $self->changed();

        splice( @{ $ref_items[ $$self ] }, $index, 0, $new_item );
        
        return;
    }

    #############################################

    sub delete {
        my $self        = shift;
        my $index       = shift;

        $self->changed();

        splice( @{ $ref_items[ $$self ] }, $index, 1 );

        return;
    }

    #############################################

    sub remove {
        my $self            = shift;
        my $item_to_remove  = shift;

        $self->changed();

        my $index = -1;

        foreach my $item ( @{ $ref_items[ $$self ] } ) {

            $index++;
			
			if ( looks_like_number( $item_to_remove ) ) {
				if ( $item == $item_to_remove ) {
					$self->delete( $index );
					last;
				}
			}
			else {
				if ( $item eq $item_to_remove ) {
					$self->delete( $index );
					last;
				}
			}
        }

        return $index;
    }

    #############################################

    sub add_list {
        my $self        = shift;
        my $list		= shift;
		
		$self->add( $list->items() );

        return;
    }

    #############################################

	sub index_of {
		my $self		= shift;
		my $item		= shift;
		
		foreach my $index ( 0 .. $self->count() - 1 ) {
		
			if ( ref( $self->item( $index ) ) ne ref( $item ) ) {
				next;
			}
		
			if ( refaddr( $self->item( $index ) ) == refaddr( $item ) ) {
				return $index;
			}
		}
		
		return -1;
	}

    #############################################
    #############################################



}

#############################################################################



#############################################################################
#############################################################################
1

