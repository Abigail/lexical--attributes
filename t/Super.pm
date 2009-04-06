package Super;

use strict;
use warnings;

#
# Ordinary Perl OO module.
#

sub new {
    my $class = shift;

    bless {} => $class;
}

sub name {
    my $self = shift;
    $$self {name};
}
sub set_name {
    my $self = shift;
    $$self {name} = shift;
}

sub colour {
    my $self = shift;
    $$self {colour};
}
sub set_colour {
    my $self = shift;
    $$self {colour} = shift;
}

sub address {
    my $self = shift;
    $$self {address};
}
sub set_address {
    my $self = shift;
    $$self {address} = shift;
}


1;

__END__

=head1 HISTORY

 $Log: Super.pm,v $
 Revision 1.2  2005/08/26 21:24:45  abigail
 New, or modified tests

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

