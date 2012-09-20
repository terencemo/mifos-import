#!/usr/bin/perl
# Name: create-offices.pl
# Purpose: Create Mifos Offices from CSV spreadsheet
# Author: Terence Monteiro
# Date: Sep 19th, 2012
# License: GNU GPL version 3
# Usage: ./create-offices.pl office-level(1-5) offices.csv
# CSV Columns:
#        1. Office Name
#        2. Short Name
#        3. Parent Office
#        4. Address Line1
#        5. Address Line2
#        6. Address Line3
#        7. Office City
#        8. Office State
#        9. Office Country
#        10. Office Zip
#        11. Office Phone Number

use strict;
use warnings;
use lib 'lib';
use Mifos::Common;
use Text::CSV_XS;
use Test::More  tests   => 3;

my $mc;

sub get_office_details {
    my $level = 1;
    my $offices = [];
    foreach my $link ($mc->find_all_links( url_regex  => qr/^offAction\.do/ )) {
        if ($link->url() =~ m/method=load/) {
            if ($link->url() =~ m/officeLevel=(\d)/) {
                $level = $1;
            }
        } elsif ($link->url() =~ m/officeId=(\d+)/) {
            my $ofId = $1;
            push(@$offices, {
                level       =>  $level,
                officeId    =>  $ofId,
                officeName  =>  $link->text()
            } );
        }
    }
    return $offices;
}

my ( $n, $csv_path ) = @ARGV;

$mc = Mifos::Common->new( conf => 'settings.conf' );

$mc->login();

sub view_offices {
    $mc->follow_link( text => 'Admin' );
    $mc->follow_link( text => 'View offices' );
}

sub create_office {
    my $n = shift;

    &view_offices;
    $mc->follow_link( url_regex => qr(offAction\.do\?method=load.+officeLevel=$n) );
}

&view_offices;

my $offices = &get_office_details();

die "Invalid usage: $0 level csv_path" unless $n =~ m/^(\d|-i)$/;

if ($n eq "-i") {

    print "Enter office level (2-5) or l for full office level: ";
    $n = <STDIN>;
    chomp $n;

    if ($n =~ m/^l$/) {
        my $l = 1;
        foreach my $lname (qw(Regional Divisional Area Branch)) {
            print ++$l . " -  $lname Office\n";
        }
        $n = <STDIN>;
        chomp $n;
    }

#        my $html = $mc->content();
#        print "Field names\n";
#        while ($html =~ /<(?=input type="text"|select).* name="(\S+)"/g) {
#            print "\t$1\n";
#        }
}

unless ($csv_path) {
    $csv_path = <STDIN>;
    chomp $csv_path;
}

die "File not found" unless -f $csv_path;

my $csv = Text::CSV_XS->new( { binary => 1 } );
open(my $fh, $csv_path);
while (my $row = $csv->getline($fh)) {
    my $po = $row->[2];
    my @par_office = grep {
         $n - 1 == $_->{level} and $_->{officeName} =~ m/$po/
    } @$offices;
    my $par_office;
    if (0 == scalar @par_office) {
        print STDERR "Office not found\n";
    } elsif (1 == scalar @par_office) {
        $par_office = $par_office[0];        
    } else {
        print STDERR "Multiple office match\n";
        foreach my $pro (@par_office) {
            print STDERR $pro->{officeId} . " : " . $pro->{officeName} . "\n";
        }
        next;
    }
    my $co = $row->[8] || "India";
    my $fields = {
        officeName  =>  $row->[0],
        shortName   =>  $row->[1],
        officeLevel =>  $n,
        parentOfficeId  =>  $par_office->{officeId},
        'address.line1' =>  $row->[3],
        'address.line2' =>  $row->[4],
        'address.line3' =>  $row->[5],
        'address.city'  =>  $row->[6],
        'address.state' =>  $row->[7],
        'address.country'   =>  $co,
        'address.zip'   =>  $row->[9],
        'address.phoneNumber'   =>  $row->[10]
    };

    if ($n =~ m/^[2-5]$/) {
        &create_office($n);
    }

    $mc->submit_form(with_fields => $fields);
#    print "\n";
#    foreach my $field (keys %$fields) {
#        my $value = $fields->{$field} || "";
#        print "$field: $value\n";
#    }
#    print "Parent office: " . $par_office->{officeId} . " : " . $par_office->{officeName} . "\n";
    $mc->submit_form(form_number => 1);
}

$mc->logout();

