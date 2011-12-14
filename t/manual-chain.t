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

my ($ac, $as, $hs);
my $s = ParenMW->new(
            inner => $ac=ArrayCache->new(
                limit => 100,
                inner => $as=ArrayStore->new(
                    limit => 10,
                    inner => $hs=HashStore->new()
                )
            )
        );

$s->set(1=>"one");
$s->set(20=>"twenty");
$s->set(x=>"ex");

is( $s->get(1),     '(one)',    '$s->get(1)' );
is( $s->get(20),    '(twenty)', '$s->get(20)' );
is( $s->get("x"),   '(ex)',     '$s->get("x")' );

is( $s->get(2),     '(UNDEF)',   '$s->get(1)' );
is( $s->get(21),    '(UNDEF)',   '$s->get(20)' );
is( $s->get("y"),   '(UNDEF)',   '$s->get("x")' );

# look at chain tails
is( $ac->get(1),    'one',       '$ac->get(1)' );   ;
is( $as->get(1),    'one',       '$as->get(1)' );
is( $hs->get(1),    undef,       '$hs->get(1)' );
is( $ac->get(20),   'twenty',    '$ac->get(20)' );
is( $as->get(20),   'twenty',    '$as->get(20)' );
is( $hs->get(20),   'twenty',    '$hs->get(20)' );
is( $ac->get("x"),  'ex',        '$ac->get("x")' );
is( $as->get("x"),  'ex',        '$as->get("x")' );
is( $hs->get("x"),  'ex',        '$hs->get("x")' );

# look inside chain segment guts:

done_testing();
