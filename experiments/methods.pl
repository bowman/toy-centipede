#!/usr/bin/perl

use strict;
use warnings;

sub A::run { print "A::run @_\n" }
my $a = bless {}, "A";

$a->run;

my $run_str = "run";
$a->$run_str;

my $run_code = \&A::run;
$a->$run_code;

$a->A::run;

my $run_fqstr = "A::run";
$a->$run_fqstr;

$a->${\"run"};

$a->${\sub { print "inline @_\n" }; };

{
package A;
#$a->__PACKAGE__::run;

my $run_pkgstr = __PACKAGE__ . "::run";
$a->$run_pkgstr;

$a->${ \(__PACKAGE__ . "::run") };
}
