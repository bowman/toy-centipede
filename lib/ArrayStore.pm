package ArrayStore;

use namespace::autoclean;
use Moose;
use mro 'c3'; # dfs might actually be better

with 'Protocol';

has as_store => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Any]',
    default => sub { [] },
    handles => {
        _as_get     => 'get',
        _as_set     => 'set',
    },
);

has as_limit => (
    is      => 'ro',
    isa     => 'Int',
    default => 100,
);

sub get {
    my ($self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->as_limit ) {
        return $self->_as_get($var);
    } else {
        return $self->next::method($var);
    }
}

sub set {
    my ($self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->as_limit ) {
        $self->_as_set($var, $val);
    } else {
        $self->next::method($var, $val);
    }
}

1;
