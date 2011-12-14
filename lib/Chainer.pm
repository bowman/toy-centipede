package Chainer;

use strict;
use warnings;
use Carp qw(croak);

sub build {
    my ($class, $params) = @_;

    my ($target_class, $extra) = keys %$params;
    return $params if ! defined $target_class;
    croak "Too many hash keys ($target_class, $extra..)" if defined $extra;

    $params = $params->{$target_class};

    my $metaclass = Class::MOP::Class->initialize($target_class);

    # find attributes that 'does' Protocol
    my @delegate_names = grep {
        my $inner;
        ($inner = $metaclass->get_attribute($_))
            and $inner->type_constraint->is_a_type_of("Protocol");
    } $metaclass->get_attribute_list;

    # extract Protocol delegates from params and build delegate (recursively)
    for my $delegate_name (@delegate_names) {
        $params->{$delegate_name} = Chainer->build($params->{$delegate_name});
    }

    # pass params and delegates to new
    return $target_class->new(%$params);
}

1;
