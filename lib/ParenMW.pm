package ParenMW;

use namespace::autoclean;
use Moose;

has inner => (
    is      => 'ro',
    does => 'Protocol',
    required => 1,
    # Protocol requires met by delegation (with later)
    handles => [qw(
        set
    )],
);

with 'Protocol';

sub get {
    my ($self, $var) = @_;
    return "(" . ($self->inner->get($var) // 'UNDEF') . ")";
}

=for delegate reference
sub set {
    my ($self, $var, $val) = @_;
    return $self->inner->set($var, $val);
}
=cut

1;
