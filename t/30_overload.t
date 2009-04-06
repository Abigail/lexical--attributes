#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    if (-d 't') {
        chdir 't' or die "Failed to chdir: $!\n";
    }

    unless (grep {m!"blib/lib"!} @INC) {
        push @INC => grep {-d} "blib/lib", "../blib/lib"
    }

    use_ok ('Overload');
}

ok (defined $Lexical::Attributes::VERSION &&
            $Lexical::Attributes::VERSION > 0, '$VERSION');


my $obj1 = Overload -> new; isa_ok ($obj1, "Overload");
my $obj2 = Overload -> new; isa_ok ($obj2, "Overload");

$obj1 -> load_me ("red", "blue", "yellow");
$obj2 -> load_me ("green", "brown"); $obj2 -> key3 ("purple");

is ("$obj1", "key1 = red; key2 = blue; key3 = yellow", "Overload");
is ("$obj2", "key1 = green; key2 = brown; key3 = purple", "Overload");

__END__

=head1 HISTORY

 $Log: 30_overload.t,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

