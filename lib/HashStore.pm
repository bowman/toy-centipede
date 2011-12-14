package HashStore;

use namespace::autoclean;
use Moose;

has store => (
    traits  => ['Hash'],
    is      => 'ro',
    # isa      => 'HashRef[Any]',
    default => sub { {} },
    handles => {
        # get/set meet 'Protocol' requires (delay with)
        get     => 'get',
        set     => 'set',
    },
);

with 'Protocol';

=for Protocol
sub get {
    my ($self, $var) = @_;
    return $self->_get($var);
}

sub set {
    my ($self, $var, $val) = @_;
    $self->_set($var, $val);
}
=cut

1;

