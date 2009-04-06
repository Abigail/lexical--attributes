use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use 5.8.1;

WriteMakefile(
    NAME              => 'Lexical::Attributes',
    VERSION_FROM      => 'lib/Lexical/Attributes.pm', # finds $VERSION
    PREREQ_PM         => {Filter::Simple => '0.78'}, # e.g., Module::Name => 1.1
);


#
# $Log: Makefile.PL,v $
# Revision 1.2  2005/03/03 00:59:04  abigail
# Requirements
#
# Revision 1.1  2005/02/25 00:24:02  abigail
# First checkin
#
#
