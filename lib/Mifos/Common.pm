package Mifos::Common;
use strict;
use warnings;
use Config::General qw(ParseConfig);
use base 'Test::WWW::Mechanize';

sub new {
    my $class = shift;
    my %args = @_;

    my %conf = ParseConfig($args{conf});
    my $self = Test::WWW::Mechanize->new();

    $self->{url} = $conf{mifos_url};
    $self->{auth} = {
        j_username  => $conf{username},
        j_password  => $conf{password}
    };
    $self->get($self->{url});
    bless $self, $class;
}

sub login {
    my $self = shift;
    
    $self->title_like(qr'Mifos', 'Found mifos');
    if ($self->content() =~ m/Welcome to Mifos/) {
        $self->submit_form(
            with_fields      =>  $self->{auth}
        );
    } else {
        $self->get($self->{url});
    }
    $self->content_contains('Home', 'Reached mifos homepage');
}

sub logout {
    my $self = shift;
    $self->follow_link_ok( {
        text_regex  => qr'Log Out'
    }, 'Logged out successfully' );
}

1;
