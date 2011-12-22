#!/usr/bin/perl

use strict;
use warnings;

use PadWalker qw( closed_over set_closed_over );
use Sub::Clone;
use Sub::Name;

my $x = 123;
my $s = subname 's', sub { print "in ", (caller(0))[3], ": x=$x\n" };
my $t = subname 't', clone_sub $s;

my ($sh)=closed_over($t);
my ($th)=closed_over($t);
$th->{'$x'}=\456;
set_closed_over($t,$th);

$s->();
$t->();
