#!/usr/bin/perl
# CSV Columns
#   1. Branch
#   2. Center Name
#   3. Loan Officer
#	4. Meeting Schedule (Weekly:DayOfWeek:Location)
#	5. MFI Joining Date (dd/mm/YYYY)
#	6. Address 1
#	7. Address 2
#	8. Address 3
#	9. District
#	10. State
#	11. Country
#	12. PIN
#	13. Telephone
#	14. Fee 1 Type
#	15. Fee 1 Amount
#	16. Fee 2 Type
#	17. Fee 2 Amount
#	18. Fee 3 Type
#	19. Fee 3 Amount

use strict;
use warnings;
use lib 'lib';
use Mifos::Importer::Selenium;
use Text::CSV_XS;
use Test::More  tests   => 3;

my $sel;

my @WEEKDAYS = qw(Monday Tuesday Wednesday Thursday Friday Saturday);

$sel = Mifos::Importer::Selenium->new( conf => 'settings.conf' );
$sel->title_like(qr'Mifos', 'Found Mifos');
$sel->login();
$sel->wait_for_page_to_load(6000);
$sel->title_like(qr'Mifos', 'Logged in');

sub goto_admin {
    $sel->click('header.link.admin');
    $sel->wait_for_page_to_load(5000);
}

sub goto_view_offices {
    $sel->click('admin.link.viewOffices');
    $sel->wait_for_page_to_load(5000);
}

sub view_offices {
    &goto_admin;
    &goto_view_offices;
}

sub get_office_details {
    &view_offices;
    my $content = $sel->get_html_source();
    while ($content=~ m/<a href="offAction\.do\?method=get&amp;officeId=(\d+)\S+ id="viewOffices\.link\.view([A-Z][a-z]+)Office">([^<]+)<\/a>/g) {
        my ( $oId, $oType, $name ) = ( $1, $2, $3 );
        print "Office id: $oId, type: $oType, name: $name\n";
    }
#    print "Content: $content\n";
#    foreach my $link ($sel->get_text('xpath=//a[contains(@href,"offAction.do?method=get&officeId")]')) {
#        print "Link: $link\n";
#    }
}

sub goto_clients_accounts {
    $sel->click('header.link.clientsAndAccounts');
    $sel->wait_for_page_to_load(5000);
}

sub goto_create_center {
    $sel->click('menu.link.label.createnewcenter');
    $sel->wait_for_page_to_load(5000);
}

sub create_new_center {
    &goto_clients_accounts;
    &goto_create_center;
}

sub schedule_meeting {
    my ( $sched, $mplace ) = @_;

    my ( $freq, @parms ) = split(/:/, $sched);
    if ($freq =~ m/^M/i) {
        $freq = "Months";
        $sel->check("createmeeting.input.frequency$freq");
    } else {
        $freq = "Weeks";
        $sel->check("createmeeting.input.frequency$freq");
        my $wkFreq;
        if ($parms[0] =~ m/^\d+$/) {
            $wkFreq = shift(@parms);
        } else {
            $wkFreq = 1;
        }
        $sel->type("createmeeting.input.weekFrequency", $wkFreq);
        my $wkday = shift(@parms);
        my ( $weekday ) = grep { m/^$wkday/i } @WEEKDAYS;
        $sel->select("createmeeting.input.dayOfWeek", $weekday);
    }
    my $place = $mplace || $parms[0];
    $sel->type("createmeeting.input.meetingPlace", $place);
    $sel->click("createmeeting.button.save");
    $sel->wait_for_page_to_load(5000);
}

#&get_office_details;

my ( $csv_path ) = @ARGV;

die "File not found" unless -f $csv_path;

my $csv = Text::CSV_XS->new( { binary => 1 } );
open(my $fh, $csv_path);
while (my $row = $csv->getline($fh)) {
    my $branch = $row->[0];
    next if (! defined $branch or ! $branch or $branch =~ m/^branch/i);
    &create_new_center;
    $sel->click("link=$branch");
    $sel->wait_for_page_to_load(5000);
    $sel->type("createnewcenter.input.name", $row->[1]);
    $sel->select("loanOfficerId", $row->[2]);
    $sel->click("createnewcenter.link.meetingSchedule");
    $sel->wait_for_page_to_load(5000);
    &schedule_meeting($row->[3], $row->[6] || $row->[7] || $branch);
    my $mjd = $row->[4];
    if ($mjd =~ m/\d{4}$/) {
        my ( $d, $m, $Y ) =
            ( $mjd =~ m/^(\d\d?)[-\/](\d\d?)[-\/](\d{4})$/ );
        $sel->type("mfiJoiningDateDD", $d);
        $sel->type("mfiJoiningDateMM", $m);
        $sel->type("mfiJoiningDateYY", $Y);
    }
    $sel->type("createnewcenter.input.address1", $row->[5]);
    $sel->type("createnewcenter.input.address2", $row->[6]);
    $sel->type("createnewcenter.input.address3", $row->[7]);
    $sel->type("createnewcenter.input.city", $row->[8]);
    $sel->type("createnewcenter.input.state", $row->[9]);
    $sel->type("createnewcenter.input.country", $row->[10]);
    $sel->type("createnewcenter.input.postalCode", $row->[11]);
    $sel->type("createnewcenter.input.telephone", $row->[12]);
    if ($row->[13]) {
        $sel->select("selectedFee[0].feeId", $row->[13]);
        $sel->select("selectedFee[0].amount", $row->[14]);
    }
    if ($row->[15]) {
        $sel->select("selectedFee[1].feeId", $row->[15]);
        $sel->select("selectedFee[1].amount", $row->[16]);
    }
    if ($row->[17]) {
        $sel->select("selectedFee[2].feeId", $row->[17]);
        $sel->select("selectedFee[2].amount", $row->[18]);
    }
    $sel->click("createnewcenter.button.preview");
    $sel->wait_for_page_to_load(5000);
    $sel->click("previewcenter.button.submit");
    $sel->wait_for_page_to_load(5000);
    print "Added new center under $branch: " . $row->[1] . "\n";
}

$sel->logout();
$sel->wait_for_page_to_load(5000);
$sel->title_like(qr'Mifos', 'Logged out of mifos');
$sel->stop;

