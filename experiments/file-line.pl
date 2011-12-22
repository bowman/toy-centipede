#!/usr/bin/perl -l

use strict;
use warnings;
no warnings 'uninitialized';

my $s;
# line 0 "A::a"
$s = sub {
 print __FILE__,__LINE__," $s: (", join(", ",caller(0)),")";
};

$s->();

# line 0 "B::b"
*B::b = sub {
 print __FILE__,__LINE__," $s: (", join(", ",caller(0)),")";
};

B->b;

sub gen {
    my $pkg = shift;
return eval '
# line 0 "'.$pkg.'"
sub {
 print __FILE__," $s: (", join(", ",caller(0)),")";
};';
}

*C::c = gen('C::c');
*D::d = gen('D::d');

C->c;D->d;
