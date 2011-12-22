package ParenMW;

use namespace::autoclean;
use Moose;
use mro 'c3';

# XXX set missing because it's passed through: with 'Protocol';

sub get {
    my ($layer_pkg, $self, $var) = @_;
    return "(" . ($self->next::method($var) // 'UNDEF') . ")";
}

=for delegate reference
sub set {
    my ($self, $var, $val) = @_;
    return $self->inner->set($var, $val);
}
=cut

1;
