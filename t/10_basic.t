#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan'; # tests => 12;
# use Test::More tests => 110;

my $N = 5;

BEGIN {
    if (-d 't') {
        chdir 't' or die "Failed to chdir: $!\n";
    }

    unless (grep {m!"blib/lib"!} @INC) {
        push @INC => grep {-d} "blib/lib", "../blib/lib"
    }

    use_ok ('Basic');
}

ok (defined $Lexical::Attributes::VERSION &&
            $Lexical::Attributes::VERSION > 0, '$VERSION');


#
# Check whether methods were created (or not).
#

for my $type (qw /s a h/) {
    no strict 'refs';
    for my $kind (qw /default pr priv/) {
        ok (!defined &{"Basic::${type}_${kind}"},
             "!defined &Basic::${type}_${kind}")
    }
    for my $kind (qw /ro rw/) {
        ok ( defined &{"Basic::${type}_${kind}"},
             " defined &Basic::${type}_${kind}")
    }
}

for my $i (1 .. 3) {
    no strict 'refs';
    ok ( defined &{"Basic::key_ro$i"}, " defined &Basic::key_ro$i");
    ok ( defined &{"Basic::key_rw$i"}, " defined &Basic::key_rw$i");
    ok (!defined &{"Basic::key_pr$i"}, "!defined &Basic::key_pr$i");
}

ok ( defined &Basic::key_rw4, " defined &Basic::key_rw4");
ok ( defined &Basic::array,   " defined &Basic::array");
ok (!defined &Basic::unused,  "!defined &Basic::unused");


#
# Can we create objects?
#
my @obj;
for (0 .. $N - 1) {
    $obj [$_] = Basic -> new;
    isa_ok ($obj [$_], "Basic");
}

for my $i (0 .. $N - 2) {
    for my $j ($i + 1 .. $N - 1) {
        ok $obj [$i] ne $obj [$j], "Different objects ($i, $j)";
    }
}


#
# Test rw functions.
#

for my $i (0 .. $N - 1) {
    $obj [$i] -> s_rw ("val-rw $i");
    $obj [$i] -> a_rw (map {"val-rw-$_"} 0 .. $i);
    $obj [$i] -> h_rw (map {+"-key-$_" => "value-rw-$i-$_"} 0 .. $i);
}
for my $i (0 .. $N - 1) {
    is ($obj [$i] -> s_rw, "val-rw $i", "s_rw return value ($i)");
    my @a = $obj [$i] -> a_rw;
    my @b = map {"val-rw-$_"} 0 .. $i;
    is_deeply \@a, \@b, "a_rw return value ($i)";
    my %a = $obj [$i] -> h_rw;
    my %b = map {+"-key-$_" => "value-rw-$i-$_"} 0 .. $i;
    is_deeply (\%a, \%b, "h_rw return value ($i)");
}


#
# Set ro values by other means.
#
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_s_ro ("val-ro $i");
    $obj [$i] -> set_a_ro (map {"val-ro-$_"} 0 .. $i);
    $obj [$i] -> set_h_ro (map {+"-key-$_" => "value-ro-$i-$_"} 0 .. $i);
}
for my $i (0 .. $N - 1) {
    is ($obj [$i] -> s_ro, "val-ro $i", "s_ro return value ($i)");
    my @a = $obj [$i] -> a_ro;
    my @b = map {"val-ro-$_"} 0 .. $i;
    is_deeply \@a, \@b, "a_ro return value ($i)";
    my %a = $obj [$i] -> h_ro;
    my %b = map {+"-key-$_" => "value-ro-$i-$_"} 0 .. $i;
    is_deeply (\%a, \%b, "h_rw return value ($i)");
}



#
# Set _pr, _priv and _default values by other means.
#
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_s_pr      ("val-pr $i");
    $obj [$i] -> set_s_priv    ("val-priv $i");
    $obj [$i] -> set_s_default ("val-def $i");
    $obj [$i] -> set_a_pr      (map {"val-pr-$_"}   0 .. $i);
    $obj [$i] -> set_a_priv    (map {"val-priv-$_"} 0 .. $i);
    $obj [$i] -> set_a_default (map {"val-def-$_"}  0 .. $i);
    $obj [$i] -> set_h_pr      (map {+"-key-$_" => "value-pr-$i-$_"}   0 .. $i);
    $obj [$i] -> set_h_priv    (map {+"-key-$_" => "value-priv-$i-$_"} 0 .. $i);
    $obj [$i] -> set_h_default (map {+"-key-$_" => "value-def-$i-$_"}  0 .. $i);
}
for my $i (0 .. $N - 1) {
    is ($obj [$i] -> get_s_pr,      "val-pr $i",     "s_pr return value ($i)");
    is ($obj [$i] -> get_s_priv,    "val-priv $i", "s_priv return value ($i)");
    is ($obj [$i] -> get_s_default, "val-def $i",   "s_def return value ($i)");

    my @a_1 = $obj [$i] -> get_a_pr;
    my @b_1 = map {"val-pr-$_"}   0 .. $i;
    is_deeply \@a_1, \@b_1, "a_pr return value ($i)";
    my @a_2 = $obj [$i] -> get_a_priv;
    my @b_2 = map {"val-priv-$_"} 0 .. $i;
    is_deeply \@a_2, \@b_2, "a_priv return value ($i)";
    my @a_3 = $obj [$i] -> get_a_default;
    my @b_3 = map {"val-def-$_"}  0 .. $i;
    is_deeply \@a_3, \@b_3, "a_default return value ($i)";

    my %a_1 = $obj [$i] -> get_h_pr;
    my %b_1 = map {+"-key-$_" => "value-pr-$i-$_"}   0 .. $i;
    is_deeply (\%a_1, \%b_1, "h_pr return value ($i)");
    my %a_2 = $obj [$i] -> get_h_priv;
    my %b_2 = map {+"-key-$_" => "value-priv-$i-$_"} 0 .. $i;
    is_deeply (\%a_2, \%b_2, "h_priv return value ($i)");
    my %a_3 = $obj [$i] -> get_h_default;
    my %b_3 = map {+"-key-$_" => "value-def-$i-$_"}  0 .. $i;
    is_deeply (\%a_3, \%b_3, "h_default return value ($i)");
}


#
# Set some keys by index.
#
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_a_default;
    for my $j (0 .. $i) {
        $obj [$i] -> array_by_index ($j, "key-index-$i-$j");
    }
}
for my $i (0 .. $N - 1) {
    my @a = $obj [$i] -> get_a_default;
    my @b = map {"key-index-$i-$_"} 0 .. $i;
    is_deeply \@a, \@b, "indexing ($i)";
}

#
# push/pop/unshift/shift/splice
#
for my $i (0 .. $N - 1) {
    $obj [$i] -> push_array (map {"key-push-$i-$_"} 0 .. $i);
}
for my $i (0 .. $N - 1) {
    my @a = $obj [$i] -> array;
    my @b = map {"key-push-$i-$_"} 0 .. $i;
    is_deeply \@a, \@b, "push ($i)";
}
for my $i (0 .. $N - 1) {
    my $a = $obj [$i] -> pop_array;
    my $b = "key-push-$i-$i";
    is ($a, $b, "pop ($i)");
    my @a = $obj [$i] -> array;
    my @b = map {"key-push-$i-$_"} 0 .. ($i - 1);
    is_deeply \@a, \@b, "popped ($i)";
}
for my $i (0 .. $N - 1) {
    $obj [$i] -> unshift_array (map {"key-unshift-$i-$_"} 0 .. $i);
}
for my $i (0 .. $N - 1) {
    my @a = $obj [$i] -> array;
    my @b = map {"key-unshift-$i-$_"} 0 .. $i;
    push @b => map {"key-push-$i-$_"} 0 .. ($i - 1);
    is_deeply \@a, \@b, "unshift ($i)";
}
for my $i (0 .. $N - 1) {
    my $a = $obj [$i] -> shift_array;
    my $b = "key-unshift-$i-0";
    is ($a, $b, "shift ($i)");
    my @a = $obj [$i] -> array;
    my @b = map {"key-unshift-$i-$_"} 1 .. $i;
    push @b => map {"key-push-$i-$_"} 0 .. ($i - 1);
    is_deeply \@a, \@b, "shifted ($i)";
}
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_array (map {"key-$i-$_"} 0 .. ($i * 2 + 1));
    my @a2 = $obj [$i] -> array;
}
for my $i (0 .. $N - 1) {
    my @a1 = $obj [$i] -> slice_array (0 .. $i);
    my @b1 = map {"key-$i-$_"} 0 .. $i;
    my @a2 = $obj [$i] -> splice_array ($i, $i + 2);
    my @b2 = map {"key-$i-$_"} $i .. (2 * $i + 1);
    my @a3 = $obj [$i] -> array;
    my @b3 = map {"key-$i-$_"} 0 .. $i - 1;
    is_deeply \@a1, \@b1, "slice ($i)";
    is_deeply \@a2, \@b2, "spliced ($i)";
    is_deeply \@a3, \@b3, "splice left ($i)";
}


#
# Hash tests.
#
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_h_default (map {+"key-$_" => "val-$i-$_"} 0 .. $i);
}
for my $i (0 .. $N - 1) {
    my %a = $obj [$i] -> get_h_default;
    my %b = map {+"key-$_" => "val-$i-$_"} 0 .. $i;
    is_deeply \%a, \%b, "get_h_default ($i)";
}
for my $i (0 .. $N - 1) {
    for my $j (0 .. $i) {
        is ($obj [$i] -> h_default_by_key ("key-$j"), "val-$i-$j",
                        "h_default_by_key ($i, $j)");
    }
}
for my $i (0 .. $N - 1) {
    $obj [$i] -> set_h_default ()
}
for my $i (0 .. $N - 1) {
    my %a = $obj [$i] -> get_h_default;
    my %b = ();
    is_deeply \%a, \%b, "empty h_default ($i)";
}
for my $i (0 .. $N - 1) {
    for my $j (0 .. $i) {
        $obj [$i] -> h_default_by_key ("key-$j" => "val2-$i-$j"),
    }
}
for my $i (0 .. $N - 1) {
    my %a = $obj [$i] -> get_h_default;
    my %b = map {+"key-$_" => "val2-$i-$_"} 0 .. $i;
    is_deeply \%a, \%b, "h_default ($i)";
}
for my $i (0 .. $N - 1) {
    my @a_k = sort $obj [$i] -> keys_h_default;
    my @b_k = map {+"key-$_"} 0 .. $i;
    my @a_v = sort $obj [$i] -> values_h_default;
    my @b_v = map {+"val2-$i-$_"} 0 .. $i;
    is_deeply \@a_k, \@b_k, "keys ($i)";
    is_deeply \@a_v, \@b_v, "values ($i)";
}
for my $i (0 .. $N - 1) {
    my @a = $obj [$i] -> slice_h_default ("key-0", "key-$i");
    my @b = ("val2-$i-0", "val2-$i-$i");
    is_deeply \@a, \@b, "hash slice ($i)";
}

#
# has (...) basic functionality.
#

my @coins = qw /euro dollar pound yen franc peso/;

for my $i (0 .. $N - 1) {
    $obj [$i] -> key_rw1 ("$coins[0]-$i");
    $obj [$i] -> key_rw2 ("$coins[1]-$i");
    $obj [$i] -> key_rw3 ("$coins[2]-$i");
    $obj [$i] -> key_rw4 ("$coins[3]-$i");
    $obj [$i] -> loader (map {+"$_-$i"} @coins);
}
for my $i (0 .. $N - 1) {
    is ($obj [$i] -> key_rw1,     "$coins[0]-$i", "get/set key_rw1");
    is ($obj [$i] -> key_rw2,     "$coins[1]-$i", "get/set key_rw2");
    is ($obj [$i] -> key_rw3,     "$coins[2]-$i", "get/set key_rw3");
    is ($obj [$i] -> key_rw4,     "$coins[3]-$i", "get/set key_rw4");
    is ($obj [$i] -> key_ro1,     "$coins[0]-$i", "get/set key_ro1");
    is ($obj [$i] -> key_ro2,     "$coins[1]-$i", "get/set key_ro2");
    is ($obj [$i] -> key_ro3,     "$coins[2]-$i", "get/set key_ro3");
    is ($obj [$i] -> get_key_pr1, "$coins[3]-$i", "get/set key_p1");
    is ($obj [$i] -> get_key_pr2, "$coins[4]-$i", "get/set key_p2");
    is ($obj [$i] -> get_key_pr3, "$coins[5]-$i", "get/set key_p3");
}


#
# How many entries?
#
my @a = Basic -> give_status;
my @b = (0, ($N) x 25);
is_deeply (\@a, \@b, "status (0)");

for my $i (0 .. $N - 1) {
    undef $obj [$i];
    my @a = Basic -> give_status;
    my @b = (0, ($N - ($i + 1)) x 25);
    is_deeply (\@a, \@b, sprintf "status (%d)" => $i + 1);
}
@a = Basic -> give_status;
@b = (0) x 26;
is_deeply (\@a, \@b, "final status");

__END__

=head1 HISTORY

 $Log: 10_basic.t,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin

