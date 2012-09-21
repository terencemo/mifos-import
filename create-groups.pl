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

sub goto_clients_accounts {
    $sel->click('header.link.clientsAndAccounts');
    $sel->wait_for_page_to_load(5000);
}

sub goto_create_group {
    $sel->click('menu.link.label.createnewgroup');
    $sel->wait_for_page_to_load(5000);
}

sub create_new_group {
    &goto_clients_accounts;
    &goto_create_group;
}

sub set_training_date {
    my $trd = shift;

    my ( $d, $m, $Y );
    if ($trd =~ m/\d{4}$/) {
        ( $d, $m, $Y ) = map { s/^0\+//; $_ }
            ( $trd =~ m/^(\d\d?)[-\/](\d\d?)[-\/](\d{4})$/ );
    } else {
        ( $Y, $m, $d ) = map { s/^0\+//; $_ }
            ( $trd =~ m/^(\d{4})[-\/](\d\d?)[-\/](\d\d?)$/ );
    }
    $sel->type("trainedDateDD", $d);
    $sel->type("trainedDateMM", $m);
    $sel->type("trainedDateYY", $Y);
#    $sel->check("trained");
}
#&get_office_details;

my ( $csv_path ) = @ARGV;

die "File not found" unless -f $csv_path;

my $csv = Text::CSV_XS->new( { binary => 1 } );
open(my $fh, $csv_path);
while (my $row = $csv->getline($fh)) {
    my $center = $row->[0];
    next if (! defined $center or ! $center or $center =~ m/^center/i);
    &create_new_group;
    $sel->type("center_search.input.search", $center);
    $sel->click("center_search.button.search");
    $sel->wait_for_page_to_load(5000);
    $sel->click("link=$center");
    $sel->wait_for_page_to_load(5000);
    $sel->type("creategroup.input.displayName", $row->[1]);
    $sel->select("formedByPersonnel", $row->[2]);
    $sel->type("creategroup.input.address1", $row->[4]);
    $sel->type("creategroup.input.address2", $row->[5]);
    $sel->type("creategroup.input.address3", $row->[6]);
    $sel->type("creategroup.input.city", $row->[7]);
    $sel->type("creategroup.input.state", $row->[8]);
    $sel->type("creategroup.input.country", $row->[9]);
    $sel->type("creategroup.input.postalCode", $row->[10]);
    $sel->type("creategroup.input.telephone", $row->[11]);
    if ($row->[12]) {
        $sel->select("selectedFee[0].feeId", $row->[12]);
        $sel->select("selectedFee[0].amount", $row->[13]);
    }
    if ($row->[14]) {
        $sel->select("selectedFee[1].feeId", $row->[14]);
        $sel->select("selectedFee[1].amount", $row->[15]);
    }
    if ($row->[16]) {
        $sel->select("selectedFee[2].feeId", $row->[16]);
        $sel->select("selectedFee[2].amount", $row->[17]);
    }
#    &set_training_date($row->[3]) if $row->[3];
#    $sel->click("creategroup.button.preview"); # somehow screws the date!
    $sel->submit("groupCustActionForm");
    $sel->wait_for_page_to_load(5000);
#    &set_training_date($row->[3]) if $row->[3];
#    $sel->submit("groupCustActionForm");
    $sel->click("previewgroup.button.submitForApproval");
    $sel->wait_for_page_to_load(5000);
    $sel->click("link=View Group details now");
    $sel->wait_for_page_to_load(5000);
    $sel->click("link=Edit Group status");
    $sel->wait_for_page_to_load(5000);
    $sel->check("newStatusId", 9);
    $sel->type("customerchangeStatus.input.notes", "Approved");
    $sel->click("customerchangeStatus.button.preview");
    $sel->wait_for_page_to_load(5000);
    $sel->click("customerchangeStatusPreview.button.submit");
    $sel->wait_for_page_to_load(5000);
#    print "Added new center under $branch: " . $row->[1] . "\n";
}

$sel->logout();
$sel->wait_for_page_to_load(5000);
$sel->title_like(qr'Mifos', 'Logged out of mifos');
$sel->stop;

