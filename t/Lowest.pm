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
    $$self {key1} = shift if @_;
    $$self {key1};
}

sub key2 {
    my $self = shift;
    $self -> SUPER::key2 (shift) if @_;
    reverse $self -> SUPER::key2;
}


1;

__END__

=head1 HISTORY

 $Log: Lowest.pm,v $
 Revision 1.2  2005/03/03 23:32:59  abigail
 Renamed Base.pm and Overload.pm because of case-insensitive filesystems

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

