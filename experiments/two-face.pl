#!/usr/bin/perl 

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

sub C::inner { "D" }
sub B::inner { $_[0]->{inner} }
sub A::inner { shift->{layers}{A}{inner} }

sub A::get { "A(". shift->inner->get( @_ ) .")"; }
sub B::get { "B{". shift->inner->get( @_ ) ."}"; }
sub C::get { "C[". shift->inner->get( @_ ) ."]"; }
sub D::get { shift; "D(@_)"; }

sub D::top { "D" }
sub C::top { shift }
sub B::top { shift->{top} }

sub A::x { shift->{x} }
sub B::x { shift->{x} }
sub C::x { "cx" }
sub D::x { "dx" }

sub A::exs { my $self = shift; "A $self x=". $self->x .", ". $self->inner->exs; }
# dispatch lookup with next::can then use topself as "invocant" (not B layer)
sub B::exs { my $self = shift; my $m = $self->next::can;
                               "B $self x=". $self->x .", ". $self->top->$m; }
# knows to start looking from C->inner
sub C::exs { my $self = shift; my $m = C->inner->can('exs');
                               "C $self x=". $self->x .", ". $self->$m; }
sub D::exs { my $self = shift; "D $self x=". $self->x ."."; }


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
