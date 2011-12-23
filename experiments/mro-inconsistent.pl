#!/usr/bin/env perl

use mro 'c3';
@A::ISA=qw(MO B);
@B::ISA=qw(MO);
sub B::a { shift->next::can("a") };

warn "@{A->mro::get_linear_isa}";
$a = bless {}, "A";
$a->a;

__END__
A MO B at -e line 1.
Inconsistent hierarchy during C3 merge of class 'A': merging failed on parent 'MO' at /usr/lib/perl/5.10/mro.pm line 24.
