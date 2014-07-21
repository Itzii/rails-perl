#!/usr/bin/perl

use strict;
use warnings;

use Rails::Screens::Main;

$| = 1;

#############################################################################

my $screen = Rails::Screens::Main->new();

my $result = $screen->process_action();

$result =~ s{ ^ \s+ }{}xms;

#if ( $result =~ m{ ^ < }xms ) {
	print $screen->header();
#}

print $result;

#############################################################################
#############################################################################
