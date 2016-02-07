use v6;
use Test;

plan 5; # 7;



my %hash = (
    choose              => 'lib/Term/Choose.pm6',
    choose_linefold     => 'lib/Term/Choose/LineFold.pm6',
    choose_linux        => 'lib/Term/Choose/Linux.pm6',
    #choose_win32        => 'lib/Term/Choose/Win32.pm6',
    choose_constants    => 'lib/Term/Choose/Constants.pm6',
);


my %version;
my %podversion;


my $c = -1;
for %hash.kv -> $k, $v {
    %version{$k}    = --$c;
    %podversion{$k} = --$c;
    for $v.IO.lines -> $line {
        if $line ~~ / ^ my \s \$VERSION \s \= \s . (\d\.\d\d\d[_\d\d]?) . \; / {
            %version{$k} = $0;
        }
        #if $line ~~ / ^ \= head1 \s VERSION / ff / ^ '=' /{
            if $$line ~~ / ^ Version \s (\S+) $/ {
                %podversion{$k} = $0;
            }
        #}
    }
}


#my $version_in_changelog = --$c;
#my $release_date = --$c;
#for '../Changes'.IO.lines ->$line {
#    if $line ~~ /^\s*(\d+\.\d\d\d[_\d\d]?)\s+(\d\d\d\d\-\d\d\-\d\d)\s*$/ {
#        $version_in_changelog = $1;
#        $release_date = $2;
#        last;
#    }
#}



my Date $today = Date.today;

ok( %version<choose> > 0, 'Version > 0  OK' );

is( %podversion<choose>,        %version<choose>, 'Version in POD Term::Choose  OK' );
is( %version<choose_linefold>,  %version<choose>, 'Version in Term::Choose::LineFold  OK' );
is(  %version<choose_linux>,    %version<choose>, 'Version in Term::Choose::Linux  OK' );
#is( %version<choose_win32>,   %version<choose>,   'Version in Term::Choose::Win32 OK' );
is( %version<choose_constants>, %version<choose>, 'Version in Term::Choose::Constants  OK' );
#is( $version_in_changelog,    %version<choose>,   'Version in "Changes"  OK' );
#is( $release_date,            $today,             'Release date in Changes is date from today  OK' );