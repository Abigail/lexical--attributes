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
    $$self {name} = shift if @_;
    $$self {name};
}

sub colour {
    my $self = shift;
    $$self {colour} = shift if @_;
    $$self {colour};
}

sub address {
    my $self = shift;
    $$self {address} = shift if @_;
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
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

