#!/usr/bin/env perl

use Test::More;
use strict;
use warnings;
use Devel::PartialDump qw(show);

BEGIN {
    use_ok('Protocol');
    use_ok('HashStore');
    use_ok('ArrayStore');
    use_ok('ArrayCache');
    use_ok('ParenMW');
}

# create a metaclass instance of an anon_class (Moose::Meta::Class=HASH..)
# then use new_object to create the anon class object
# (Class::MOP::Class::__ANON__::SERIAL::4=HASH)
# definition_context for attributes { line => , file||description => }
# attribute in layer vs self
my $protocol_meta = Class::MOP::Class->initialize('Protocol');
my @protocol_methods = map { $_->name }
                        $protocol_meta->get_required_method_list;

my $prev;
my (%layer_meta, %layer_class);
for my $layer_pkg (qw( HashStore ArrayStore ArrayCache ParenMW )) {
    my $layer_meta = Class::MOP::Class->initialize($layer_pkg);
#warn $layer_meta->name, ": $prev, ", $layer_meta->superclasses;
    my $layer_class = Class::MOP::Class->create_anon_class(
        #superclasses => [ $layer_meta->superclasses, ($prev // ()) ],
        superclasses => [ ($prev // ()), $layer_meta->superclasses ],
        attributes => [ map { $layer_meta->get_attribute($_) }
                            $layer_meta->get_attribute_list ],
        # package not needed
    )->new_object();

    for my $protocol_method (@protocol_methods) {
        next unless $layer_meta->has_method($protocol_method);
        my $m = $layer_meta->get_method($protocol_method)->clone(
                package_name => $layer_meta->name,
                associated_metaclass => $layer_meta,
        );
        # $m->detach_from_class;
        $layer_meta->add_method( $m->name, $m );
    }

    $layer_meta{$layer_pkg} = $layer_meta;
    $layer_class{$layer_pkg} = $layer_class;
    $prev = $layer_meta->name;
}

# new instance of the anonymous subclass of HashStore
# (don't provide 'inner' as that is now handled by anon class inheriting)
my $hs = $layer_class{HashStore}->new();
my $as = $layer_class{ArrayStore}->new(as_limit => 10); # param no use
my $ac = $layer_class{ArrayCache}->new(ac_limit => 20); # param no use
my $s  = $layer_class{ParenMW}->new(as_limit => 10, ac_limit => 20);

my $hs_pkg = ref $hs;
my $as_pkg = ref $as;
my $ac_pkg = ref $ac;
my $s_pkg  = ref $s;

$s->set(1=>"one");
$s->set(20=>"twenty");
$s->set(30=>"thirty");
$s->set(x=>"ex");
#warn join ",\n ", @{ mro::get_linear_isa( $s_pkg ) };

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
is( $s->$hs_get(20),   'twenty',    '$hs->get(20)' );
is( $s->$ac_get(30),   'thirty',    '$ac->get(30)' );
is( $s->$as_get(30),   'thirty',    '$as->get(30)' );
is( $s->$hs_get(30),   'thirty',    '$hs->get(30)' );
is( $s->$ac_get("x"),  'ex',        '$ac->get("x")' );
is( $s->$as_get("x"),  'ex',        '$as->get("x")' );
is( $s->$hs_get("x"),  'ex',        '$hs->get("x")' );

# look inside chain segment guts:

done_testing();
