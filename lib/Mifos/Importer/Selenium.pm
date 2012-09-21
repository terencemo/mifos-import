package Mifos::Importer::Selenium;
use strict;
use warnings;
use Config::General qw(ParseConfig);
use base 'Test::WWW::Selenium';

sub new {
    my $class = shift;
    my %args = @_;

    my %conf = ParseConfig($args{conf});
    my $url = $conf{mifos_url};
    my $self = Test::WWW::Selenium->new( host => "localhost",
                                 port => 4444,
                                 browser => "*firefox3 /usr/lib/iceweasel/firefox-bin",
                                 browser_url => $url
                             );

    $self->{url} = $url;
    $self->{auth} = {
        username  => $conf{username},
        password  => $conf{password}
    };
    $self->start;
    $self->open($url);
    bless $self, $class;
}

sub login {
    my $self = shift;
    
    $self->type("j_username", $self->{auth}->{username});
    $self->type("j_password", $self->{auth}->{password});
    $self->click("login.button.login"); # submit button
}

sub logout {
    my $self = shift;
    $self->click('logout_link');
}

1;
