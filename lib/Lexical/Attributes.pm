package Lexical::Attributes;

use strict;
use warnings;
use Filter::Simple;
use Scalar::Util;

our ($VERSION) = q $Revision: 1.1 $ =~ /[\d.]+/g;

my $sigil     = '[$@%]';
my $sec_sigil = '[.]';
my $trait     = '(?:r[ow]|pr(?:iv)?)';        # read-only, read-write, private.
my $name      = qr /[a-zA-Z_][a-zA-Z0-9_]*/;  # Starts with alpha or _, followed
                                              # by one or more alphanumunders.
my $attribute = qr /(?>$sigil$sec_sigil$name)/;

my %attributes;

sub declare_attribute {
    my ($attributes, $trait) = @_;

    $trait = "pr" if !$trait || $trait eq "priv";

    my $str = "";

    foreach my $attribute (split /\s*,\s*/ => $attributes) {

        my ($sigil, $sec_sigil, $name) = unpack "A A A*" => $attribute;

        if ($attributes {$name}) {
            warn "Duplicate attribute '$attribute' ignored\n";
            next;
        }

        $attributes {$name} = [$sigil, $trait];

        $str .= "my %$name;";
        unless ($trait eq "pr") {
            $str .= " sub $name {my \$_key = Scalar::Util::refaddr shift;";
            if ($sigil eq '$') {
                $str .= " \$$name {\$_key}  = shift  if \@_;" if $trait eq "rw";
                $str .= " \$$name {\$_key};";
            }
            elsif ($sigil eq '@') {
                $str .= " \@{\$$name {\$_key}} = \@_ if \@_;" if $trait eq "rw";
                $str .= " \@{\$$name {\$_key}}";
            }
            elsif ($sigil eq '%') {
                $str .= " \%{\$$name {\$_key}} = \@_ if \@_;" if $trait eq "rw";
                $str .= " \%{\$$name {\$_key}}";
            }
            else {
                die "'$attribute' not implemented\n";
            }
            $str .= "}";
        }
    }
    
    return $str;
}

sub destroy_attributes {
    my $str;
    while (my ($key) = each %attributes) {
        #$str .= "delete \$$key {\$_key};";
        $str .= "delete \$$key {Scalar::Util::refaddr \$self};";
    }
    $str;
}

sub use_attribute {
    my ($attribute) = @_;

    my ($sigil, $sec_sigil, $name) = unpack "A A A*" => $attribute;

    if (!$attributes {$name}) {
        die $_;
        die qq !Attribute "$attribute" requires declaration!;
    }

    my $str;
    if ($sigil eq '$') {
        $str = "\$$name {Scalar::Util::refaddr \$self}";
    }
    elsif ($sigil eq '@') {
        $str = "\@{\$$name {Scalar::Util::refaddr \$self}}";
    }
    elsif ($sigil eq '%') {
        $str = "\%{\$$name {Scalar::Util::refaddr \$self}}";
    }
    else {
        die "Sigil '$sigil' not implemented yet!\n";
    }
    $str;
}

FILTER_ONLY 
    # Initialize variables.
    all   => sub {%attributes = ()},

    # Save all attributes found in comments. *Very* simple heuristics
    # to determine comments - note that quote like constructs have been
    # moved out of the way.
    #
    # Moving away the attributes found in comments prevents subsequent
    # passes to modify them. In particular, outcommented attribute
    # declarations shouldn't create methods or hashes. 
    code => sub {
        1 while s/(                   # Save
                    (?<!$sigil)       # Not preceeded by a sigil
                    \#                # Start of a comment.
                    [^\n]*            # Not a newline, not an attribute,
                    (?: $sigil (?!$sec_sigil) [^\n]*)*
                                      # using standard unrolling.
                  ) ($sigil) ($sec_sigil) ($name)
                 /$1$2<$3>$4/xg;
    },

    # Find the attribute declarions and uses. Foreach declararion, the sub
    # 'attribute' is called, which will create an attribute hash,
    # and, for non-private attributes, a constructor (which maybe
    # an lvalue method if the rw trait is given).
    #
    # We recognize:
    #    "has"     [$@%][.:]attribute ( ("is")? "rw")? ";"
    #    "has" "(" [$@%][.:]attribute ("," [$@%][.:]attribute)* ")" \
    #                                 ( ("is")? "rw")? ";"
    #
    # Other attribute usages are just:
    #              [$@%].:attribute
    #
    # Attribute uses are handled by calling 'use_attribute'.
    #
    code  => sub {
        s{(?:                    # Declaration using 'has',
            \bhas \s*                       # Must start with "has"
             (?:                            # Either 
                      ($attribute)          #   a single ttribute, stored in $1.
               |                            # or
              [(] \s* ($attribute (?: \s* , \s* $attribute)*) \s* [)]
                                            #   an attribute list, stored in $2.
             )
             (?: \s* (?:is \s+)? ($trait))? # Optional trait - stored in $3.
             \s* ;                          # Terminated by semi-colon.
          ) |                    # or actual usage.
           ($attribute)                     # It's in $4.
         }
         {$4 ? use_attribute ($4) : declare_attribute ($1 || $2, $3)}egx;
    },

    # Restore tucked away, outcommented, attributes.
    code => sub {
        1 while s/(                   # Save
                    (?<!$sigil)       # Not preceeded by a sigil
                    \#                # Start of a comment.
                    [^\n]*            # Not a newline, not an attribute,
                    (?: $sigil (?!<$sec_sigil>) [^\n]*)*
                                      # using standard unrolling.
                  ) ($sigil) <($sec_sigil)> ($name)
                 /$1$2$3$4/xg;
    },

    # Handle DESTROY. Three cases:
    #   1.  __DESTROY__ is used, presumably inside a DESTROY sub.
    #   2.  No __DESTROY__, but there's a DESTROY sub.
    #   3.  No __DESTROY__, and no DESTROY sub. In that case, a DESTROY
    #       sub is added to the end.
    code => sub {
        my $destroy = destroy_attributes;

        # Found __DESTROY__
        s<\b__DESTROY__\b><$destroy>g                                         or

            # Found DESTROY subroutine
            s<^(\s* sub \s+ DESTROY \s* (?: \([^)]*\) \s*)? \{ [^\n]*)>
             <$1 do {my \$self = \$_ [0]; $destroy};>mx                       or

            $_ .= "sub DESTROY {my \$self = shift; $destroy}";
    },

    # Add assignments to $self and $_key to all subroutines that start
    # with a trailing '{' on the declaration line. (A bit Spiffy like).
    # Subs named 'new' will be excluded. Note that DESTROY is *not* excluded.
    code => sub {
        s<^(\s* sub \s+ (?!new\b)[a-zA-Z]\w* \s*  # sub name
            (?:\([^)]*\) \s*)?                    # Optional prototype
            \{ [\ \t]*) \n                        # Opening block
          ><$1 my \$self = shift;\n>mgx;
    },

    # For debugging purposes; to be removed.
    all   => sub {print "<<$_>>\n"},
;

__END__

=head1 NAME

Lexical::Attributes - Proper encapsulation

=head1 SYNOPSIS

    use Lexical::Attributes;

    has $.scalar;
    has $.key ro;
    has (@.array, %.hash) is rw;

    sub method {
        $self -> another_method;
        print $.scalar;
    }

=head1 DESCRIPTION

B<NOTE>: This is experimental software! Certain thing will change, 
specially if they are marked B<FIXME> or mentioned on the B<TODO>
list.

This module was created out of frustration with Perl's default OO 
mechanism, which doesn't offer good data encapsulation. I designed
the technique of I<Inside-Out Objects> several years ago, but I was
not really satisfied with it, as it still required a lot of typing.
This module uses a source filter to hide the details of the Inside-Out
technique from the user.

Attributes, the variables that belong to an object, are stored in lexical
hashes, instead of piggy-backing on the reference that makes the object.
The lexical hashes, one for each attribute, are indexed using the object.
However, the details of this technique are hidden behind a source filter.
Instead, attributes are declared in a similar way as lexical variables.
Except that instead of C<my>, a Perl6 keyword, C<has> is used. Another 
thing is borrowed from Perl6, and that's the second sigil. Attributes 
have a dot separating the sigil from the name of attribute.

=head2 Attributes

To declare an attribute, use the Perl6 keyword C<has>. The simplest way to
declare an attribute is:

    has $.colour;    # Gives the object a 'colour' attribute.

Now your object has an attribute I<colour>. Note the way the attribute is
written, in a Perl6 style, it has the sigil (a C<$>), a period, and then
the attribute name. Attribute names are strings of letters, digits and 
underscores, and cannot start with a digit. Attribute names are case-sensitive.
You can use this attribute in the same way as a normal Perl scalar (except
for interpolation). Here's a sub that prints out the colour of the object:

    sub print_colour {
        print $.colour;
    }

Array and hash attributes work in a similar way:

    has @.array;   # Gives the object an array attribute.
    has %.hash;    # Gives the object a hash attribute.

And you can use them in a similar way as you can with "normal" Perl variables:

    sub first_element {
        return $.array [0];
    }

    sub pop_element {
        return pop @.array;
    }

    sub gimme_key {
        my $key = shift;
        return $.hash {$key};
    }

    sub gimme_all_keys {
        return keys %.hash;
    }

Note however that you I<cannot> have a scalar and an array (or a scalar 
and a hash, or an array and a hash) with the same name. Using both
C<has $.key;> and C<has @.key;> will result in a warning, and the second
(and third, fourth, etc) declaration of the attibute will be B<ignored>.

If you have several attributes you want to declare, you can use C<has>
in a similar way as you can C<my> and C<local>. C<has> takes a list as
argument as well (parenthesis are required):

    has ($.key1, @.key2, %.key3);

Note that the declaration, that is, the C<has> keyword followed by an 
attribute, or a list of attributes, can be followed by an optional
I<trait> (as discussed below), B<must> be followed by a semi-colon
(after optional whitespace). The following will not work:

    has $.does_not_work = 1;

=head3 Traits

Since inspecting and setting the attributes of an object is a commonly
requested action, it's possible to give the attributes I<traits> that
will achieve this. Traits are given by following the C<has> declaration
with the keyword C<is> and the name of the trait (with the keyword being
optional). Examples include:

    has $.get_set is rw;
    has $.get ro;
    has (@.array, %.hash) is priv;   # Trait applies to both attributes.

The following traits can be given:

=over 5

=item C<pr> or C<priv>

Using C<pr> or C<priv> has the same effect as not giving any traits,
no accessor for this attribute is generated.

=item C<ro>

This trait generates an accessor for the attribute. Only the value
of the attribute can be fetched. The name of the accessor will be
the same as the name of the attribute. Any parameters given to the
accessor will be ignored.

    package MyObject;
    use Lexical::Attributes;

    has $.colour is ro;

    sub new {bless [] => shift}
    sub some_sub {
        ...  # Some code that sets the 'colour' attribute.
    }

    1;

    __END__

    # Main program

    my $obj = MyObject -> new;
    $obj -> some_sub (...);
    print $obj -> colour;   # Prints the colour.

Accessors for arrays and hashes return the array or hash (flattened to
a list).

=item C<rw>

This traits generates an accessor that can be used to fetch the value,
or the set the value. If no parameters are given, the value is fetched.
If values are given, the attribute will be given these values. If multiple
arguments are given to an accessor setting a scalar attribute, the attribute
will be set to the first argument, other arguments are ignored.

    package MyObject;
    use Lexical::Attributes;

    has ($.scalar, @.array) is rw;
    sub new {bless [] => shift;

    __END__

    # Main program
    my $obj = MyObject -> new;
    $obj -> scalar ("hello, world");
    $obj -> array (qw /tic tac toe/);

    print $obj -> scalar;             # Prints 'hello, world'.
    print join "-" => $obj -> array;  # Prints 'tic-tac-toe'.

B<FIXME>: With this interface, it's not possible to set an array (or hash)
to an empty set.

=back

=head2 Methods

In order for the module to access the attributes, it needs access to
the variable holding the current object. It will assume this variable
is called C<$self>. This is not likely to be a problem, as it seems
to be quite common to name the variable holding the current object
C<$self>.

To further add the programmer, every subroutine, with the exception of
the ones listed below, will have C<my $self = shift;> added to the
beginning of their body. This is what most OO modules start with anyway.
Excluded are:

=over 4

=item C<new> 

Subroutines named C<new> are typically constructors - for those
having a C<$self> doesn't make sense.

=item C<_name>

Subroutines whose name start with an underscore are considered private.
In fact, they well could not be method, but an ordinary, class-level,
subroutine. 

=item C<{ something>

Also, subroutines who have any non-white space after their opening
brace and before the following newline will be left untouched. This
allows you to flag a subroutine should be left as is with for instance,
a comment character.

=back

Examples:

    # Don't need to declare $self.
    sub my_method {
        $.attribute + $self -> other_method;
    }

    # Return first argument, even if that's the current object
    sub _private {
        return $_ [0];
    }

    # $_ [0] is the class name, as 'new' subroutines are exempt.
    sub new {
        bless [] => shift;   
    }

Note that if you use a method that doesn't get the assignment to C<$self>
added, and you use a C<$.attribute> type of attribute, you must put an
assignment to C<$self> before the use of the attribute.

=head2 DESTROY

Since the attributes are stored in lexical hashes, attributes do not get
garbage collected via a reference counting mechanism when the object goes
out of scope. In order to clean up attribute data, action triggered by 
the call of C<DESTROY> is needed. Hence, this module will insert a C<DESTROY>
subroutine, or modify an existing C<DESTROY> subroutine. There are three cases.

=over 4

=item *

If there is no C<DESTROY> subroutine found, a C<DESTROY> will be added.
This new subroutine will clean up attribute data, and nothing else.
It will B<not> call a C<DESTROY> method in an inherited class.
B<FIXME>: Call C<SUPER::DESTROY> if there is one.

=item *

There is a C<DESTROY> subroutine, and it doesn't contain the token
C<__DESTROY__>. Then it will put the code to clean up the attributes 
on the same line as the opening brace, assuming the current object to
be in C<$_ [0]>. It won't modify C<@_>, and it won't create a C<$self>.
B<FIXME>: This should probably change.

=item *

There's a C<__DESTROY__> token. Then this token will be replaced by 
the code that cleans up the attributes. This is useful if you want to
make use of the attributes inside a C<DESTROY> function -- without a
C<__DESTROY__> token, the attributes will be cleaned up at the beginning
of the C<__DESTROY__> function. Note that I<any> C<__DESTROY__> will 
be replaced by attribute cleaning code Then this token will be replaced by 
the code that cleans up the attributes. This is useful if you want to
make use of the attributes inside a C<DESTROY> function -- without a
C<__DESTROY__> token, the attributes will be cleaned up at the beginning
of the C<__DESTROY__> function. It is assumed that C<$self> exists at
this point. (If the opening brace of the body is followed by just whitespace,
$self will be auto-declared as mentioned above.) Note that I<any>
C<__DESTROY__> will be replaced by attribute cleaning code - even if
placed inside another method. It's safe to use it inside strings though.

    sub DESTROY {
        ... do something with attributes ...
        __DESTROY___
        ... attributes are now undefined ...
    }

=back

=head2 Inheritance

Inheritance just works. Classes using this technique require I<nothing>
from their super class implementation, and demand I<nothing> from the
classes that will inherit them. Super classes can use this technique, or
traditional hash based objects, or something else entirely. And it's
the same for classes that will inherit our classes.

=head2 Interpolation

One cannot interpolate attributes. At least, not yet. This will be fixed.

=head2 Overloading

Overloading of objects should work in the same way as other types of objects.

=head1 TODO

=over 4

=item o

Attributes should interpolate.

=item o

Rethink the generated methods for setting arrays and hashes.
Not being able to set arrays or hashes to empty arrays or hashes
is a real pain.

=item o

C<$#.array> needs to work.

=item o

If generating a C<DESTROY> subroutine, check whether a C<DESTROY> subroutine
is inherited, and call this subroutine if exists.

=item o

Modifying an existing C<DESTROY> subroutine could be done better.

=item o

Compiling a module is slow. This is probably caused by FILTER_ONLY being slow.

=item o

Consider more traits. Methods for pop/push/shift/unshift for arrays, and 
keys/values/each for hashes would be useful. So are getting/setting keys
by index.

=back

=head1 AUTHOR

Abigail, I<abigail@abigail.nl>

=head1 HISTORY

 $Log: Attributes.pm,v $
 Revision 1.1  2005/02/25 00:24:02  abigail
 First checkin



=head1 LICENSE
 
This program is copyright 2004 - 2005 by Abigail.
 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
     
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 INSTALLATION

To install this module type the following:

   perl Makefile.PL
   make
   make test
   make install

=cut

