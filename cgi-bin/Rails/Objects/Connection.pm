package Rails::Objects::Connection;

use strict;
use warnings;

#################

{
	use Object::InsideOut;
	use DBI();
	use DBD::SQLite;
	
    my @db_connection   :Field  						:Get(connection);
    my @ipaddress       :Field  :Default( '127.0.0.1' )	:Get(ip_address);
    my @error_callback  :Field												:Arg(error_callback);
    my @bark_if_error   :Field  :Default( 0 )			:Std(bark_if_error)	:Arg(bark_if_error);
    my @last_rows       :Field  :Default( 0 )			:Get(affected_rows); 
	
	my @trace			:Field	:Default( 0 )								:Arg(tron);

	my %init_args :InitArgs = (
		'fake_ip_address'	=> 0,
		'server'			=> '',
		'database'			=> '',
		'login'				=> '',
		'password'			=> '',
	);

    #############################################

    sub _init :Init {
        my $self    = shift;
		my $args	= shift;
		
		if ( defined( $ENV{'REMOTE_ADDR'} ) ) {
			$self->set( \@ipaddress, $ENV{'REMOTE_ADDR'} );
#			print "\n+++ set ip address to: " . $ENV{'REMOTE_ADDR'} . " +++\n";
		}
		
		if ( defined( $args->{'fake_ip_address'} ) ) {
			if ( $args->{'fake_ip_address'} == 1 ) {
				$self->set( \@ipaddress, '555.555.555.555' );
			}
		}

		$self->connect( 
			$args->{'server'}, 
			$args->{'database'}, 
			$args->{'login'}, 
			$args->{'password'} 
		);

        return;
    }

    #############################################

    sub _destroy :Destroy {
        my $self    = shift;

        if ( ! defined( $db_connection[ $$self ] ) ) {
            return;
        }

        $self->connection()->disconnect();

        return;
    }

    #############################################

    sub error { # No test
        my $self    = shift;
        my $message = shift;
		
        if ( defined( $error_callback[ $$self ] ) ) {
            &{ $error_callback[ $$self ] }( $message );
        }
		
		print STDERR "\n!!! $message !!!\n";
		

        return;
    }

    #############################################

    sub connect {
        my $self    	= shift;
		my $server		= shift;
		my $database	= shift;
		my $login		= shift;
		my $password	= shift;
		
        $self->set( 
			\@db_connection, 
			DBI->connect(
				'DBI:SQLite:dbname=' . $database,
				$login,
				$password,
#				{ 'RaiseError' => $self->get_bark_if_error(), 'PrintError' => 0 }
				{ 'RaiseError' => 1, 'PrintError' => 1 }
			)
		);
		
		if ( $trace[ $$self ] == 1 ) {
			$self->connection()->trace( 2, \*STDOUT );
		}

        return;
    }

    #############################################

	sub disconnect {
		my $self	= shift;
		
		$self->connection()->disconnect();
	}

    #############################################

    sub sql {
        my $self    = shift;
        my $sql     = shift;
        my @args    = @_;

        $sql =~ s{ ^ \s+ }{}xmsg;
        $sql =~ s{ \s+ $ }{}xmsg;

        $last_rows[ $$self ] = 0;
		
		my @local_args = ();
		my @ref_counts = ();
		
		foreach my $arg ( @args ) {
			if ( ref( $arg ) eq 'ARRAY' ) {
				push( @ref_counts, scalar( @{ $arg } ) );
				push( @local_args, @{ $arg } );			
			}
			else {
				push( @local_args, $arg );
			}
		}	
		
		while ( $sql =~ m{ \?\? }xms ) {
			my $holder = join( ',', ('?') x shift( @ref_counts )  );
			
			if ( $holder eq '' ) {
				$holder = 'null';
			}
			
			$sql =~ s{ \?\? }{$holder}xms;	
		}
		
        my $handle = $self->connection()->prepare( $sql );
		
        eval {
            $handle->execute( @local_args );
            $last_rows[ $$self ] = $handle->rows;
            1;
        }
        or do {
            $handle->finish;
            if ( $self->get_bark_if_error() == 1 ) {
                $self->error( 'DBI Error: ' . $@ );
            }
        };

        my $response;
        my @results;
        if ( $sql =~ m{ ^ SELECT }xmsi || $sql =~ m { ^ SHOW }xmsi ) {
            while( $response = $handle->fetchrow_hashref ) {
                push( @results, $response );
            }
        }
                                                                                                                                                                                                          
        $handle->finish;

        return @results;
    }

	#############################################
	
	sub simple_exec {
        my $self    = shift;
        my $sql     = shift;
        my @args    = @_;

        $self->sql( $sql, @args );

        return $self->affected_rows();
    }

    #############################################

    sub check_for_value {
        my $self    = shift;
        my $sql     = shift;

        if ( $sql =~ m{ \s value [\s,] }xms ) {
            return 1;
        }

        $self->error( 'Missing "value" field in query.' );
        return 0;
    }

    #############################################
    
    sub simple_value {
        my $self    = shift;
        my $default = shift;
        my $sql     = shift;
        my @args    = @_;

        unless( $self->check_for_value( $sql ) == 1 ) {
            return $default;
        }

        my @records = $self->sql( $sql, @args );

        unless( @records ) {
            return $default;
        }
		
		if ( defined( $records[ 0 ]->{'value'} ) ) {
			return $records[ 0 ]->{'value'};
		}
		
		return $default;
    }

    #############################################
	
	sub simple_list {
		my $self		= shift;
		my $sql			= shift;
		my @args		= @_;
		
        unless( $self->check_for_value( $sql ) == 1 ) {
            return ();
        }
		
        my @records = $self->sql( $sql, @args );
		
		my @list = ();

        foreach ( @records ) {
            push( @list, $_->{'value'} );
        }

        return @list;
	}

    #############################################

    sub simple_add_to_list {
        my $self        = shift;
        my $ref_list    = shift;
        my $sql         = shift;
        my @args        = @_;

        unless( $self->check_for_value( $sql ) == 1 ) {
            return @{ $ref_list };
        }
		
        my @records = $self->sql( $sql, @args );

        foreach ( @records ) {
            push( @{ $ref_list }, $_->{'value'} );
        }

        return @{ $ref_list };
    }

    #############################################

    sub simple_hash {
        my $self        = shift;
        my $sql         = shift;
        my @args        = @_;

        unless( $self->check_for_value( $sql ) == 1 ) {
            return ();
        }

        unless( $sql =~ m{ \s keyfield [\s,] }xms ) {
            $self->error( 'Missing "keyfield" field in query.' );
            return ();
        }

        my @records = $self->sql( $sql, @args );
		
		my %hash;
		
        foreach ( @records ) {
            $hash{ $_->{'keyfield'} } = $_->{'value'};
        }

        return %hash;
    }
	
    #############################################

    sub simple_add_to_hash {
        my $self        = shift;
        my $ref_hash    = shift;
        my $sql         = shift;
        my @args        = @_;

        if ( ! defined( $ref_hash ) ) {
            $ref_hash   = {};
        }

        unless( $self->check_for_value( $sql ) == 1 ) {
            return $ref_hash;
        }

        unless( $sql =~ m{ \s keyfield [\s,] }xms ) {
            $self->error( 'Missing "keyfield" field in query.' );
            return $ref_hash;
        }

        my @records = $self->sql( $sql, @args );

        foreach ( @records ) {
            $ref_hash->{ $_->{'keyfield'} } = $_->{'value'};
        }

        return %{ $ref_hash };
    }

    #############################################

    sub duprecord {
        my $self            = shift;
        my $table           = shift;
        my $id_field        = shift;
        my $orig_id         = shift;
        my $new_id          = shift;
        my @ignore_fields   = @_;
		
		$id_field = $self->safe_identifier( $id_field );
                                                
        my @records = $self->sql( 
            "SELECT * FROM $table WHERE $id_field=?", 
            $orig_id 
        );

        unless ( @records ) {
            return '';
        }
                                                                                                            
        my @testrecords = $self->sql( 
            "SELECT * FROM $table WHERE $id_field=?", 
            $new_id 
        );

        unless ( @records ) {
            return '';
        }
                                                                                                                                                                        
        my $o_rec = $records[ 0 ];

        delete( $o_rec->{ $id_field } );
        for ( @ignore_fields ) {
            delete( $o_rec->{ $_ } );
        }
                                                                                                                                                                                                                                        
        my @fieldnames = keys( %{ $o_rec } );
        my @fieldvalues;
        my @placeholders;
        foreach ( @fieldnames ) { 
            push( @placeholders, $_ . '=?' );
            push( @fieldvalues, $o_rec->{ $_ } );
        }
                                                                                                                                                                                                                                                                                                                    
        my $sql = "UPDATE $table SET " . join( ',', @placeholders ) . " WHERE $id_field=?";
		
	    $self->sql( $sql, @fieldvalues, $new_id );
                
        return $new_id; 
    }

    #############################################
	
	sub safe_identifier {
		my $self	= shift;
		my $text	= shift;

		my $allowed = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890';

		my @letters = split( //, $text );
		my @finals = ();

		foreach my $letter ( split( //, $text ) ) {
			if ( $allowed =~ m{ $letter }xms ) {
				push( @finals, $letter );
			}
		}

		return join( '', @finals );
	}
	
	#############################################


}

#############################################################################



#############################################################################
#############################################################################
1
