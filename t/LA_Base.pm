package LA_Base;

use strict;
use warnings;
use Super;
use Lexical::Attributes;

our @ISA = qw /Super/;

has ($.name, $.colour);
has ($.age, $.key1, $.key2) is rw;

method base_name {
    $.name;
}
method set_base_name {
    $.name = shift;
}

method base_colour {
    $.colour;
}
method set_base_colour {
    $.colour = shift;
}

method address {
    reverse $self -> SUPER::address;
}

method my_set_key2 {
    $.key2 = shift;
}

1;

__END__

=head1 HISTORY

 $Log: LA_Base.pm,v $
 Revision 1.3  2005/08/26 21:24:45  abigail
 New, or modified tests

 Revision 1.2  2005/03/03 23:32:59  abigail
 Renamed Base.pm and Overload.pm because of case-insensitive filesystems

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

