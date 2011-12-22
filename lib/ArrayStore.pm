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
# my $limit = __PACKAGE__ . "::limit";

sub get {
    my ($layer_pkg, $self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->as_limit ) {
        return $self->_as_get($var);
    } else {
        return $self->${ \($layer_pkg->inner->can('get')) }($var);
    }
}

sub set {
    my ($layer_pkg, $self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->as_limit ) {
        $self->_as_set($var, $val);
    } else {
        return $self->${ \($layer_pkg->inner->can('set')) }($var, $val);
    }
}

1;
