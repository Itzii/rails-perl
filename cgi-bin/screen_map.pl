#!/usr/bin/perl

use strict;
use warnings;

use Rails::Screens::Map;

$| = 1;

#############################################################################

my $screen = Rails::Screens::Map->new();

my $result = $screen->process_action();

$result =~ s{ ^ \s+ }{}xms;

#if ( $result =~ m{ ^ < }xms ) {
	print $screen->header();
#}

print $result;

#############################################################################
#############################################################################
