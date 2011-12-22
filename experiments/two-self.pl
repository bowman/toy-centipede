#!/usr/bin/perl 
# $self->method(@args) at end of chain
# $dispatch_via->method($self, @args) internally

use strict;
use warnings;
use YAML::XS;
use mro 'c3';

# A -> B -> C -> D

@C::ISA = 'D';
@B::ISA = 'C';
@A::ISA = 'B';

sub D::pkg { "D" }
sub C::pkg { "C" }
sub B::pkg { "B" }
sub A::pkg { "A" }

# inner hard coded at assembly time
sub C::inner { "D" }
# inner available via $layer object
# (can a static layer pkg map to an inner object?)
sub B::inner { $_[0]->{inner} }
sub A::inner { shift->{layers}{A}{inner} }
# inner map in object, universal, each $disp can be object or pkg
# (if different inner names are wanted? _layers{ pkg => (object or pkg) } ?)
# sub inner { $_[1]->_inners->{ref($_[0]) || $_[0]}
# sub inner { $_[1]->_inners->{$_[0]->pkg}
# A -> B 4 combinations (p|o)->(p|o)
# pp: p->inner->meth($self)
# op: o->inner->meth($self) # inner looks in o, gets back pkg
# oo: o->inner->meth($self) # inner looks in o, gets back inner o
# po: p->inner->meth($self) # p can only use hard-coded vals, o can't be h/c in sub
# sub inner { $_[1]->_inners->{ref($_[0]) || $_[0]}
# po: p->inner(s)->meth(s)  # inner can look in s, with p, to find inner
# s->layer { pkg => (pkg || obj) } used to find o for p
# if p->inner->meth(s) used ip for dispatch, ip can find o = s->layer(ip)
# s->layer could omit pkg=>pkg maps, only pkg=>obj needed

sub A::get  { my $s=shift; $s->_get( $s, @_ ); }
sub A::_get { "A(". shift->inner->_get( @_ ) .")"; }
sub B::_get { "B{". shift->inner->_get( @_ ) ."}"; }
sub C::_get { "C[". shift->inner->_get( @_ ) ."]"; }
sub D::_get { shift; shift; "D(@_)"; }

sub A::x { shift->{x} }
sub B::x { shift->{x} }
sub C::x { "cx" }
sub D::x { "dx" }

sub A::exs  {
    my $self = shift; $self->_exs($self); }

sub A::_exs {
    my ($disp, $self) = (shift, shift);
    return "\n A $disp,$self x=". $self->x .", ". $disp->inner->_exs($self); }
# dispatch lookup with next::can then use topself as "invocant" (not B layer)
sub B::_exs {
    my ($disp, $self) = (shift, shift);
    # my $m = $disp->next::can(); # can't pass who next is: Ah not A
    return "\n B $disp,$self x=". $disp->x .", ". $disp->inner->_exs($self); }
# knows to start looking from C->inner
sub C::_exs {
    my ($disp, $self) = (shift, shift);
    return "\n C $disp,$self x=". $disp->x .", ". $disp->inner->_exs($self); }
sub D::_exs {
    my ($disp, $self) = (shift, shift);
    return "\n D $disp,$self x=". $disp->x ."."; }


my $out_face = bless {
        x => "ax", y => "why",
        layers => {
            # A => { inner => 'Breplaces' },
            A => (bless { inner => 'Brepl' }, 'A'),
            B => (bless { inner => 'C', top => 'Arepl', x=>'bx' }, 'B'),
            C => 'C',
            D => 'D',
        },
    }, "A";
$out_face->{layers}{A}{inner} = $out_face->{layers}{B};
$out_face->{layers}{B}{top} = $out_face;

print Dump($out_face);

print "get: ", $out_face->get("hello"), "\n";

$_ = $out_face;
do { print "$_ ->inner\n" }
    while ($_->can('inner') and $_ = $_->inner);

print "exs: ", $out_face->exs(), "\n";

$_="last_line" for (1..100); # for debugger
