package NoDestroy;

use strict;
use warnings;
use Lexical::Attributes;

has $.private_key;
has $.simple_key   is ro;
has $.settable_key is rw;

sub new {
    bless [] => shift;
}

sub load_me {
    $.private_key  = $_ [0] if @_;
    $.simple_key   = $_ [1] if @_ > 1;
    $.settable_key = $_ [2] if @_ > 2;
}

sub count_keys { # Leave me
   (scalar keys %simple_key,
    scalar keys %private_key,
    scalar keys %settable_key,)
}


1;

__END__

=head1 HISTORY

 $Log: NoDestroy.pm,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

