use ExtUtils::MakeMaker;

WriteMakefile(
    NAME    => 'mifos-import',
    VERSION_FROM => 'lib/Mifos/Common.pm',
    EXE_FILES   => [ 'create-groups.pl', 'create-centers.pl', 'create-offices.pl' ],
    PREREQ_PM   => {
        'Test::WWW::Mechanize'  => 1.30,
        'Test::WWW::Selenium'   => 1.33
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (AUTHOR         => 'Terence Monteiro <terencemo@cpan.org>') : ()),
       LICENSE        => 'gpl'
);

