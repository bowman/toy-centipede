package ParenMW;

use namespace::autoclean;
use Moose;
use mro 'c3';

with 'Protocol';

has inner => (
    is => 'ro',
    does => 'Protocol',
);

sub get {
    my ($self, $var) = @_;
    return "(" . ($self->next::method($var) // 'UNDEF') . ")";
}

sub set {
    my ($self, $var, $val) = @_;
    return $self->next::method($var, $val);
}

1;
