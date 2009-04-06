package Duplicate;

use strict;
use warnings;

use Lexical::Attributes;

has $.key is ro;
has $.key;
# has $.something;

sub new {
    bless [] => shift;
}

1;

__END__

=head1 HISTORY

 $Log: Duplicate.pm,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

