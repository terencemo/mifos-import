Mifos Import
============

Mifos Import is a set of Perl scripts to import data into Mifos. Currenty, the
following data can be imported:

 * Offices (all levels) - Regional, Divisional, Area, Branch Offices
 * Centres
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

  - Office Name
  - Short Name
  - Parent Office
  - Address Line1
  - Address Line2
  - Address Line3
  - Office City
  - Office State
  - Office Country
  - Office Zip
  - Office Phone Number

Then run the following command:

  perl create-offices.pl offices.csv

Importing Centres
-----------------

This requires the Selenium standalone server running. Download it from
http://seleniumhq.org/download/ and run it as follows:

    $ java -jar selenium-server-standalone-<version>.jar

Then, create a CSV with the office details having the following columns:

  - Branch
  - Center Name
  - Loan Officer
  - Meeting Schedule (e.g Weekly:DayOfWeek:Location)
  - MFI Joining Date (dd/mm/YYYY)
  - Address 1
  - Address 2
  - Address 3
  - District
  - State
  - Country
  - Postal Code (PIN/ZIP)
  - Telephone
  - Fee 1 Type
  - Fee 1 Amount
  - Fee 2 Type
  - Fee 2 Amount
  - Fee 3 Type
  - Fee 3 Amount

Importing Groups
----------------

As with centres, this requires the Selenium standalone server running. Create a
CSV with the group details having the following columns:

  - Center
  - Group Name
  - Recruited by (loan officer name)
  - Training Date (dd/mm/YYYY)
  - Address 1
  - Address 2
  - Address 3
  - District/City
  - State
  - Country
  - Postal Code (PIN/ZIP)
  - Telephone
  - Fee 1 Type
  - Fee 1 Amount
  - Fee 2 Type
  - Fee 2 Amount
  - Fee 3 Type
  - Fee 3 Amount
