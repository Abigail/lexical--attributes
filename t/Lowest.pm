package Lowest;

use strict;
use warnings;

use Base;
our @ISA = qw /Base/;

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
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

