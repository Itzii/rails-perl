package Base::Objects::Base;

use strict;
use warnings;

###############

{
    use Object::InsideOut qw( Base::Objects::Changeable Base::Objects::Connectable );
    use Base::Objects::Connection;

	my @config			:Field	:Default( undef )	:Std(config)		:Arg(config);

    #############################################

    sub _init :Init {
        my $self        = shift;

        return;
    }

    #############################################

	sub clear_flags {
		my $self	= shift;
		
		$self->Base::Objects::Changeable::clear_flags();
		$self->Base::Objects::Connectable::clear_flags();
		
		return;
	}
	
    #############################################

    sub make_new {
        my $self        = shift;
		
		$self->Base::Objects::Changeable::make_new();
		$self->Base::Objects::Connectable::make_new();

        return;
    }
	
    #############################################
	
	sub set_id {
		my $self		= shift;
		my $value		= shift;
		
		$self->Base::Objects::Connectable::set_id( $value );
		$self->changed();
		
		return;
	}

    #############################################
    #############################################
    

}

#############################################################################




#############################################################################
#############################################################################
1
