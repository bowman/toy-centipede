package HashStore;

use namespace::autoclean;
use Moose;


has hs_store => (
    traits  => ['Hash'],
    is      => 'ro',
    # isa      => 'HashRef[Any]',
    default => sub { {} },
    handles => {
        # get/set meet 'Protocol' requires (delay with)
        _hs_get     => 'get',
        _hs_set     => 'set',
    },
);

with 'Protocol';

sub get {
    my ($layer_pkg, $self, $var) = @_;
    return $self->_hs_get($var);
}

sub set {
    my ($layer_pkg, $self, $var, $val) = @_;
    $self->_hs_set($var, $val);
}

1;

