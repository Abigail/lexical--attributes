package Lowest;

use strict;
use warnings;

use LA_Base;
our @ISA = qw /LA_Base/;

#
# Ordinary Perl OO module.
#

sub new {
    my $class = shift;

    bless {} => $class;
}

sub key1 {
    my $self = shift;
    $$self {key1};
}
sub set_key1 {
    my $self = shift;
    $$self {key1} = shift;
}

sub key2 {
    my $self = shift;
    reverse $self -> SUPER::key2;
}
sub set_key2 {
    my $self = shift;
    $self -> SUPER::set_key2 (shift);
}


1;

__END__

=head1 HISTORY

 $Log: Lowest.pm,v $
 Revision 1.3  2005/08/26 21:24:45  abigail
 New, or modified tests

 Revision 1.2  2005/03/03 23:32:59  abigail
 Renamed Base.pm and Overload.pm because of case-insensitive filesystems

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

