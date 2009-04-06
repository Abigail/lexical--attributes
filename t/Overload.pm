package Overload;

use strict;
use warnings;
use Lexical::Attributes;

use overload '""' => \&stringify;

has ($.key1, $.key2);
has $.key3 is rw;

sub new {
    bless [] => shift;
}

sub load_me {
    $.key1 = shift if @_;
    $.key2 = shift if @_;
    $.key3 = shift if @_;
}

sub stringify {
    "key1 = " . $.key1 . "; key2 = " . $.key2 . "; key3 = " . $.key3;
}

1;

__END__

=head1 HISTORY

 $Log: Overload.pm,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

