package Base::Objects::Changeable;

use strict;
use warnings;

###############

{
    use Object::InsideOut;

    my @isnew           :Field  :Default( 0 )		:Get(is_new);
    my @changed         :Field  :Default( 0 )		:Get(has_changed);

    #############################################

    sub _init :Init {
        my $self        = shift;
		
        return;
    }

    #############################################

    sub clear {
        my $self        = shift;

        $self->clear_flags();

        return;
    }

    #############################################

    sub clear_flags {
        my $self        = shift;

        $self->clear_changed();
        $self->not_new();

        return;
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

    sub make_new {
        my $self        = shift;

        $self->set( \@isnew, 1 );
		
        return;
    }

    #############################################

    sub not_new {
        my $self        = shift;

        $self->set( \@isnew, 0 );

        return;
    }

    #############################################
    #############################################
    

}

#############################################################################

#############################################################################
#############################################################################
1
