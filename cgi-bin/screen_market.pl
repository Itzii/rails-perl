#!/usr/bin/perl

use strict;
use warnings;

use Rails::Screens::Market;

$| = 1;

#############################################################################

my $screen = Rails::Screens::Market->new();

my $result = $screen->process_action();

$result =~ s{ ^ \s+ }{}xms;

if ( $result =~ m{ ^ < }xms ) {
	print $screen->header();
}

print $result;

#############################################################################
#############################################################################
