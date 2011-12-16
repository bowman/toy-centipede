package ParenMW;

use namespace::autoclean;
use Moose;
use mro 'c3';

has inner => (
    is      => 'ro',
    does => 'Protocol',
    #required => 1,
    # Protocol requires met by delegation (with later)
    #handles => [qw(
    #    set
    #)],
);

# XXX set missing because it's passed through: with 'Protocol';

sub get {
    my ($self, $var) = @_;
    return "(" . ($self->next::method($var) // 'UNDEF') . ")";
}

=for delegate reference
sub set {
    my ($self, $var, $val) = @_;
    return $self->inner->set($var, $val);
}
=cut

1;
