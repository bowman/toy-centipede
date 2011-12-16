package ArrayCache;

use namespace::autoclean;
use Moose;
use mro 'c3';

with 'Protocol';

has ac_store => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Any]',
    default => sub { [] },
    handles => {
        _ac_get     => 'get',
        _ac_set     => 'set',
    },
);

has ac_limit => (
    is      => 'ro',
    isa     => 'Int',
    default => 100,
);

sub get {
    my ($self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        return $self->_ac_get($var) // $self->next::method($var);
    } else {
        return $self->next::method($var);
    }
}

sub set {
    my ($self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        $self->_ac_set($var, $val);
        $self->next::method($var, $val);
    } else {
        $self->next::method($var, $val);
    }
}

1;
