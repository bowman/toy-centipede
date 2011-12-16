#!/usr/bin/env perl

use Test::More;
use strict;
use warnings;
BEGIN {
    use_ok('HashStore');
    use_ok('ArrayStore');
    use_ok('ArrayCache');
    use_ok('ParenMW');
}

# create a metaclass instance of an anon_class (Moose::Meta::Class=HASH..)
# then use new_object to create the anon class object
# (Class::MOP::Class::__ANON__::SERIAL::4=HASH)
my $hs_class = Class::MOP::Class->create_anon_class(
    superclasses => [ 'HashStore' ],
)->new_object();

# $hs_class->meta->name || ref($hs_class)
my $as_class = Class::MOP::Class->create_anon_class(
    superclasses => [ 'ArrayStore', ref($hs_class) ],
)->new_object();

my $ac_class = Class::MOP::Class->create_anon_class(
    superclasses => [ 'ArrayCache', ref($as_class) ],
)->new_object();

my $pa_class = Class::MOP::Class->create_anon_class(
    superclasses => [ 'ParenMW', ref($ac_class) ],
)->new_object();

# new instance of the anonymous subclass of HashStore
# (don't provide 'inner' as that is now handled by anon class inheriting)
my $hs = $hs_class->new();
my $as = $as_class->new(as_limit => 10);
my $ac = $ac_class->new(ac_limit => 100);
my $s  = $pa_class->new();

my $hs_pkg = ref $hs;
my $as_pkg = ref $as;
my $ac_pkg = ref $ac;
my $s_pkg  = ref $s;

$s->set(1=>"one");
$s->set(20=>"twenty");
warn join ",\n ", @{ mro::get_linear_isa( $s_pkg ) };
warn $s->can('set');
$s->set(x=>"ex");

is( $s->get(1),     '(one)',    '$s->get(1)' );
is( $s->get(20),    '(twenty)', '$s->get(20)' );
is( $s->get("x"),   '(ex)',     '$s->get("x")' );

is( $s->get(2),     '(UNDEF)',   '$s->get(1)' );
is( $s->get(21),    '(UNDEF)',   '$s->get(20)' );
is( $s->get("y"),   '(UNDEF)',   '$s->get("x")' );

# can't look at chain tails because all state is in $s's attributes
my $ac_get = "$ac_pkg\::get";
my $as_get = "$as_pkg\::get";
my $hs_get = "$hs_pkg\::get";
is( $s->$ac_get(1),    'one',       '$ac->get(1)' );
is( $s->$as_get(1),    'one',       '$as->get(1)' );
is( $s->$hs_get(1),    undef,       '$hs->get(1)' );
is( $s->$ac_get(20),   'twenty',    '$ac->get(20)' );
is( $s->$as_get(20),   'twenty',    '$as->get(20)' );
is( $s->$hs_get(20),   undef,       '$hs->get(20)' );
is( $s->$ac_get("x"),  'ex',        '$ac->get("x")' );
is( $s->$as_get("x"),  'ex',        '$as->get("x")' );
is( $s->$hs_get("x"),  'ex',        '$hs->get("x")' );

# look inside chain segment guts:

done_testing();
