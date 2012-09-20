Mifos Import
============

Mifos Import is a set of Perl scripts to import data into Mifos. Currenty, the
following data can be imported:

 * Offices (all levels) - Regional, Divisional, Area, Branch Offices
 * Centers
 * Groups

Usage Instructions
------------------

Download the source scripts, and run the following commands:

    perl Makefile.PL
    make 

Create a file settings.conf with your mifos login configuration, like:

    mifos_url   http://mifos-domain.com
    username    mifos
    password    testmifos

Importing Offices
-----------------

To import offices, create a CSV with the office details having the following
columns:

  1. Office Name
  1. Short Name
  1. Parent Office
  1. Address Line1
  1. Address Line2
  1. Address Line3
  1. Office City
  1. Office State
  1. Office Country
  1. Office Zip
  1. Office Phone Number

Then run the following command:

    perl create-offices.pl offices.csv

Importing Centers
-----------------

This requires the Selenium standalone server running. Download it from
http://seleniumhq.org/download/ and run it as follows:

    $ java -jar selenium-server-standalone-<version>.jar

Then, create a CSV with the office details having the following columns:

  1. Branch
  1. Center Name
  1. Loan Officer
  1. Meeting Schedule (e.g Weekly:DayOfWeek:Location)
  1. MFI Joining Date (dd/mm/YYYY)
  1. Address 1
  1. Address 2
  1. Address 3
  1. District
  1. State
  1. Country
  1. Postal Code (PIN/ZIP)
  1. Telephone
  1. Fee 1 Type
  1. Fee 1 Amount
  1. Fee 2 Type
  1. Fee 2 Amount
  1. Fee 3 Type
  1. Fee 3 Amount

Import the centers by running the script:

    perl create-centers.pl centers.csv

Importing Groups
----------------

As with centers, this requires the Selenium standalone server running. Create a
CSV with the group details having the following columns:

  1. Center
  1. Group Name
  1. Recruited by (loan officer name)
  1. Training Date (dd/mm/YYYY)
  1. Address 1
  1. Address 2
  1. Address 3
  1. District/City
  1. State
  1. Country
  1. Postal Code (PIN/ZIP)
  1. Telephone
  1. Fee 1 Type
  1. Fee 1 Amount
  1. Fee 2 Type
  1. Fee 2 Amount
  1. Fee 3 Type
  1. Fee 3 Amount

Import the groups by running the script:

    perl create-groups.pl groups.csv

