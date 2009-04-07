use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use 5.008001;

WriteMakefile(
    NAME              => 'Lexical::Attributes',
    VERSION_FROM      => 'lib/Lexical/Attributes.pm', # finds $VERSION
    PREREQ_PM         => {Filter::Simple => '0.78',Test::More => 0}, # e.g., Module::Name => 1.1
    ($ExtUtils::MakeMaker::VERSION ge '6.48'? 
     (MIN_PERL_VERSION => 5.008001,
      META_MERGE => {
        resources=> {
          repository => 'http://github.com/Abigail/lexical--attributes/tree',
        },
        keywords => ['Perl6','OOP'],
      },
      LICENSE		=> 'unrestricted',
     ) : ()),
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
