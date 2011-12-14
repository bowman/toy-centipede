#!/usr/bin/env perl

use Test::More;
use YAML::XS qw(LoadFile);
use strict;
use warnings;
BEGIN {
    use_ok('HashStore');
    use_ok('ArrayStore');
    use_ok('ArrayCache');
    use_ok('ParenMW');
    use_ok('Chainer');
}

my $chain_data = LoadFile('chain.yaml');
my $s = Chainer->build($chain_data);

$s->set(1=>"one");
$s->set(20=>"twenty");
$s->set(x=>"ex");

is( $s->get(1),     '(one)',    '$s->get(1)' );
is( $s->get(20),    '(twenty)', '$s->get(20)' );
is( $s->get("x"),   '(ex)',     '$s->get("x")' );

is( $s->get(2),     '(UNDEF)',   '$s->get(1)' );
is( $s->get(21),    '(UNDEF)',   '$s->get(20)' );
is( $s->get("y"),   '(UNDEF)',   '$s->get("x")' );

done_testing();
