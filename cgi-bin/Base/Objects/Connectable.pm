package Base::Objects::Connectable;

use strict;
use warnings;

###############

{
    use Object::InsideOut;
    use Base::Objects::Connection;

    my @id              :Field  :Default( 0 )   	:Get(get_id);
    my @isvalid         :Field  :Default( 0 )		:Get(is_valid);
	
    my @connection      :Field  :Default( undef )	:Get(connection)    :Arg( 'name' => 'connection', 'Mandatory' => 1 );
    my @doctype         :Field  :Default( '' )  	:Std(doctype)   	:Arg(doctype);
    my @islockable      :Field  :Default( 0 )   	:Std(lockable)   	:Arg(is_lockable);

    my @docnumber       :Field  :Default( '' )  	:Get(get_docnumber);
	
    #############################################

    sub _init :Init {
        my $self        = shift;

        if ( ! defined( $connection[ $$self ] ) ) {
			$self->set( \@islockable, 0 );
        }

        return;
    }

	#############################################    

	sub set_id {
        my $self        = shift;
        my $id          = shift;

		$self->set( \@id, $id );

        return;
    }

    #############################################

    sub set_docnumber {
        my $self        = shift;
        my $docnumber   = shift;

        if ( $self->get_docnumber() eq $docnumber ) {
            return $docnumber;
        }

		$self->set( \@docnumber, $docnumber );

        return $docnumber;
    }

    #############################################

    sub clear {
        my $self        = shift;

		$self->set( \@isvalid, 0 );
		$self->set( \@id, -1 );
		$self->set( \@docnumber, '' );

        return;
    }

	#############################################
	
	sub clear_flags {
		my $self		= shift;

        $self->make_valid();
		
		return;
	}
	
    #############################################

    sub make_new {
        my $self        = shift;
		
        return;
    }

    #############################################
    
    sub make_valid {
        my $self        = shift;

        $self->set( \@isvalid, 1 );

        return;
    }

    #############################################
    
    sub not_valid {
        my $self        = shift;

        $self->set( \@isvalid, 0 );

        return;
    }

    #############################################
    #############################################
    

}

#############################################################################

#############################################################################
#############################################################################
1