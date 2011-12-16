package ArrayCache;

use namespace::autoclean;
use Moose;
use NEXT;

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
#my $limit = __PACKAGE__ . "::limit";

sub get {
    my ($self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        return $self->_ac_get($var) // $self->NEXT::get($var);
    } else {
        return $self->NEXT::get($var);
    }
}

sub set {
    my ($self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        $self->_ac_set($var, $val);
        $self->NEXT::set($var, $val);
    } else {
        $self->NEXT::set($var, $val);
    }
}

1;
