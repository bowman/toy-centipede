package Chainer;

use strict;
use warnings;
use Carp qw(croak);
use Class::Load qw(load_class);
use Moose::Meta::Class;
use Sub::Clone;
use Sub::Name;

my $protocol_meta = Moose::Meta::Class->initialize('Protocol');
my @protocol_methods = map { $_->name }
                        $protocol_meta->get_required_method_list;

sub build {
    my ($class, $params) = @_;

    my ($prelayer_pkg, $extra) = keys %$params;
    return $params if ! defined $prelayer_pkg;
    croak "Too many hash keys ($prelayer_pkg, $extra..)" if defined $extra;

    # { ArrayCache => { limit => 100, ...} } ===> { limit => 100, ...}
    $params = $params->{$prelayer_pkg};

    load_class($prelayer_pkg);
    my $prelayer_meta = Class::MOP::Class->initialize($prelayer_pkg);

    # find $prelayer_meta attribute(s) that 'does' Protocol
    my @delegate_names = grep {
        my $inner;
        ($inner = $prelayer_meta->get_attribute($_))
            and $inner->type_constraint->is_a_type_of("Protocol");
    } $prelayer_meta->get_attribute_list;

    # extract Protocol delegates from params and build delegate (recursively)
    for my $delegate_name (@delegate_names) {
        # get back a new object of a new layer-class
        $params->{$delegate_name} = Chainer->build($params->{$delegate_name});
    }
    my @delegate_pkgs = map { $params->{$_}->meta->name } @delegate_names;

    # setup new class for this layer:
    my $layer_meta = Moose::Meta::Class->create_anon_class(
        superclasses => [ @delegate_pkgs, $prelayer_meta->superclasses ],
        attributes => [ map { $prelayer_meta->get_attribute($_) }
                            $prelayer_meta->get_attribute_list ],
        # roles => [ $prelayer_meta->calculate_all_roles ],
        # package not needed
    );
    my $layer_class = $layer_meta->new_object();
    my $layer_pkg = $layer_meta->name;

    # deep-clone $prelayer methods into $layer
    for my $protocol_method (@protocol_methods) {
        next unless $prelayer_meta->has_method($protocol_method);

        # $orig_meth->clone-ing the method isn't enough,
        # mro needs the right subname on the CODE
        # see mro/Calling "next::method" from methods defined outside the class
        # error: No next::method 'set' found for Class::MOP::Class::__ANON__..

        my $orig_meth = $prelayer_meta->get_method($protocol_method);
        my $new_fq_name = $layer_meta->name . "::" . $orig_meth->name;
        my $new_body = subname $new_fq_name, clone_sub($orig_meth->body);
        $layer_meta->add_method( $orig_meth->name, $new_body );
    }

    # each layer must to Protocol, might do other things
    $layer_meta->add_role($_) for $prelayer_meta->calculate_all_roles;

    # create a new object with params params and delegates
    return $layer_pkg->new(%$params);
}

1;
