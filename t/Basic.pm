package Basic;

use strict;
use warnings;
use Lexical::Attributes;

has $.s_default;
has $.s_ro   is ro;
has $.s_pr   is pr;
has $.s_priv is priv;
has $.s_rw   is rw;

has @.a_default;
has @.a_ro   ro;
has @.a_pr   pr;
has @.a_priv priv;
has @.a_rw   rw;

has %.h_default;
has %.h_ro   is ro;
has %.h_pr   is pr;
has %.h_priv is priv;
has %.h_rw   is rw;

has @.array rw;

has ($.key_pr1, $.key_pr2, $.key_pr3);
has ($.key_ro1, $.key_ro2, $.key_ro3) ro;
has ($.key_rw1, $.key_rw2, $.key_rw3) is rw;
has ($.key_rw4) rw;

has ($.unused);

sub new {
    bless [] => shift;
}

sub give_status { # Class method.
   (scalar keys %unused,       #  0
    scalar keys %s_default,    #  1
    scalar keys %s_ro,         #  2
    scalar keys %s_pr,         #  3
    scalar keys %s_priv,       #  4
    scalar keys %a_default,    #  5
    scalar keys %a_ro,         #  6
    scalar keys %a_pr,         #  7
    scalar keys %a_priv,       #  8
    scalar keys %a_rw,         #  9
    scalar keys %h_default,    # 10
    scalar keys %h_ro,         # 11
    scalar keys %h_pr,         # 12
    scalar keys %h_priv,       # 13
    scalar keys %h_rw,         # 14
    scalar keys %array,        # 15
    scalar keys %key_pr1,      # 16
    scalar keys %key_pr2,      # 17
    scalar keys %key_pr3,      # 18
    scalar keys %key_ro1,      # 19
    scalar keys %key_ro2,      # 20
    scalar keys %key_ro3,      # 21 
    scalar keys %key_rw1,      # 22
    scalar keys %key_rw2,      # 23
    scalar keys %key_rw3,      # 24
    scalar keys %key_rw4,      # 25
   );
}

#
# Set _ro functions.
#
sub set_s_ro {
    $.s_ro = shift;
}
sub set_a_ro {
    @.a_ro = @_;
}
sub set_h_ro {
    %.h_ro = @_;
}

#
# Set _pr functions.
#
sub set_s_pr {
    $.s_pr = shift;
}
sub set_a_pr {
    @.a_pr = @_;
}
sub set_h_pr {
    %.h_pr = @_;
}

#
# Get _pr functions.
#
sub get_s_pr {
    $.s_pr;
}
sub get_a_pr {
    @.a_pr;
}
sub get_h_pr {
    %.h_pr;
}


#
# Set _priv functions.
#
sub set_s_priv {
    $.s_priv = shift;
}
sub set_a_priv {
    @.a_priv = @_;
}
sub set_h_priv {
    %.h_priv = @_;
}

#
# Get _priv functions.
#
sub get_s_priv {
    $.s_priv;
}
sub get_a_priv {
    @.a_priv;
}
sub get_h_priv {
    %.h_priv;
}


#
# Set _default functions.
#
sub set_s_default {
    $.s_default = shift;
}
sub set_a_default {
    @.a_default = @_;
}
sub set_h_default {
    %.h_default = @_;
}

#
# Get _default functions.
#
sub get_s_default {
    $.s_default;
}
sub get_a_default {
    @.a_default;
}
sub get_h_default {
    %.h_default;
}



#
#  Test indexing in array.
#
sub array_by_index {
    my $index = shift;
    $.a_default [$index] = shift if @_;
    $.a_default [$index]
}

#
#
#
sub set_array {
    @.array = @_;
}


#
#  push/pop/shift/unshift/slice an array.
#
sub push_array {
    push @.array => @_;
}
sub pop_array {
    pop @.array
}
sub unshift_array {
    unshift @.array => @_;
}
sub shift_array {
    shift @.array
}
sub splice_array {
    my ($from, $len) = splice @_, 0, 2;
    splice @.array => $from, $len => @_;
}
sub slice_array {
    @.array [@_]
}


#
# $#.array
#
sub count_array {
    $#.array;
}

#
# Hash functionality
#
sub h_default_by_key {
    my $key = shift;
    $.h_default {$key} = shift if @_;
    $.h_default {$key};
}
sub get_h_default_by_slice {
    @.h_default {@_}
}
sub keys_h_default {
    keys %.h_default;
}
sub values_h_default {
    values %.h_default;
}
sub slice_h_default {
    @.h_default {@_}
}


sub loader {
    $.key_ro1 = shift if @_;
    $.key_ro2 = shift if @_;
    $.key_ro3 = shift if @_;
    $.key_pr1 = shift if @_;
    $.key_pr2 = shift if @_;
    $.key_pr3 = shift if @_;
}

sub get_key_pr1 {
    $.key_pr1
}
sub get_key_pr2 {
    $.key_pr2
}
sub get_key_pr3 {
    $.key_pr3
}

1;

__END__

=head1 HISTORY

 $Log: Basic.pm,v $
 Revision 1.2  2005/03/03 00:57:45  abigail
 Tests for 0.array

 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

