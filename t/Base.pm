package Base;

use strict;
use warnings;
use Super;
use Lexical::Attributes;

our @ISA = qw /Super/;

has ($.name, $.colour);
has ($.age, $.key1, $.key2) is rw;

sub base_name {
    $.name = shift if @_;
    $.name;
}

sub base_colour {
    $.colour = shift if @_;
    $.colour;
}

sub address {
    reverse $self -> SUPER::address;
}

sub set_key2 {
    $.key2 = shift;
}

1;

__END__

=head1 HISTORY

 $Log: Base.pm,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

