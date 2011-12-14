package ArrayStore;

use namespace::autoclean;
use Moose;

with 'Protocol';

has inner => (
    is      => 'ro',
    does => 'Protocol',
    required => 1,
);

has store => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Any]',
    default => sub { [] },
    handles => {
        _get     => 'get',
        _set     => 'set',
    },
);

has limit => (
    is      => 'ro',
    isa     => 'Int',
    default => 100,
);

sub get {
    my ($self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->limit ) {
        return $self->_get($var);
    } else {
        return $self->inner->get($var);
    }
}

sub set {
    my ($self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->limit ) {
        $self->_set($var, $val);
    } else {
        $self->inner->set($var, $val);
    }
}

1;
