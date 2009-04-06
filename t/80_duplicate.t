#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 7;

BEGIN {
    if (-d 't') {
        chdir 't' or die "Failed to chdir: $!\n";
    }

    unless (grep {m!"blib/lib"!} @INC) {
        push @INC => grep {-d} "blib/lib", "../blib/lib"
    }

    my @warnings;
    local $SIG {__WARN__} = sub {push @warnings => @_};

    use_ok ('Duplicate');

    ok   (@warnings, 'Warning');
    ok   (@warnings == 1, 'Warnings on one line');
    like ($warnings [0], qr /Duplicate attribute/, 'Duplicate attribute');
}

#
# Object should still work.
#
my $obj = Duplicate -> new;
ok ($obj, "Object");

ok (defined &Duplicate::key, "Method");
ok (!defined $obj -> key, "Method should return undef");

__END__

=head1 HISTORY

 $Log: 80_duplicate.t,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

