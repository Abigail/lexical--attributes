use ExtUtils::MakeMaker;

my %args = (
    NAME                 => 'Lexical::Attributes',
    VERSION_FROM         => 'lib/Lexical/Attributes.pm',
    ABSTRACT_FROM        => 'lib/Lexical/Attributes.pm',
    PREREQ_PM            => {Filter::Simple => '0.78'},
    MIN_PERL_VERSION     =>  5.008001,
    AUTHOR               => 'Abigail <lexical-attributes@abigail.be>',
    LICENSE		 => 'mit',
    META_MERGE           => {
        build_requires   => {Test::More => 0},
        resources        => {
            repository   => 'git://github.com/Abigail/lexical--attributes.git',
        },
        keywords         => [qw [Objects Encapsulation Attributes Strict]],
    },
);

my %filter = (
    MIN_PERL_VERSION     => '6.48',
    META_MERGE           => '6.46',
    AUTHOR               => '6.07',
    ABSTRACT_FROM        => '6.07',
    LICENSE              => '6.07',
);


delete $args {$_} for grep {defined $filter {$_} &&
                            $ExtUtils::MakeMaker::VERSION lt $filter {$_}}
                            keys %args;


WriteMakefile %args;
