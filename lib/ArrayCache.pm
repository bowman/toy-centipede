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
#my $limit = __PACKAGE__ . "::limit";

sub get {
    my ($layer_pkg, $self, $var) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        return $self->_ac_get($var) // $self->${ \($layer_pkg->inner->can('get')) }($var);
    } else {
        return $self->${ \($layer_pkg->inner->can('get')) }($var);
    }
}

sub set {
    my ($layer_pkg, $self, $var, $val) = @_;
    # store small int keys in array, fallback to inner
    if ( $var =~ /^\d+$/ && $var <= $self->ac_limit ) {
        $self->_ac_set($var, $val);
        #warn "?? ", $layer_pkg->can('set');
        #warn "++ ", Class::MOP::Class::__ANON__::SERIAL::8->can('set');
        #warn "++ ", ($layer_pkg->meta->superclasses)[0]->can('set');
        #warn "++ ", $layer_pkg->inner->can('set');
        #warn "++ ", $layer_pkg->inner;
        $self->${ \($layer_pkg->inner->can('set')) }($var, $val);
    } else {
        $self->${ \($layer_pkg->inner->can('set')) }($var, $val);
    }
}

1;
