package LA_Overload;

use strict;
use warnings;
use Lexical::Attributes;

use overload '""' => \&stringify;

has ($.key1, $.key2);
has $.key3 is rw;

sub new {
    bless [] => shift;
}

method load_me {
    $.key1 = shift if @_;
    $.key2 = shift if @_;
    $.key3 = shift if @_;
}

method stringify {
    my $foo = "###"; $foo =~ s/foo/bar/;
    qq !key1 = ! . $.key1 . "; key2 = " . $.key2 . '; key3 = ' . $.key3;
}

1;

__END__

=head1 HISTORY

 $Log: LA_Overload.pm,v $
 Revision 1.3  2005/08/26 21:24:45  abigail
 New, or modified tests

 Revision 1.2  2005/03/03 23:35:05  abigail
 Renamed Base.pm and Overload.pm because of case-insensitive filesystems

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

