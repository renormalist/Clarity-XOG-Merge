package Clarity::XOG::Command::selftest;

use strict;
use warnings;

use Test::More;
use Test::Deep;
use XOG -command;
use Clarity::XOG::Merge;

use File::Temp qw(tempfile tempdir);

# ----- evaluate result -----
my $counter_Resource          = 0;
my $counter_Project           = 0;
my $counter_CustomInformation = 0;
my @projects = ();

sub abstract { "built-in self test" }

sub description {

        "Built-in self test.

Merge some self-contained dummy xml files into a temporary result file
and executes plausibility checks.

This is to check for general working, like XML parsing, create and
cleanup temp files, etc.

Expected output is some 'ok' lines and number of tests, eg. '1..4'."}

sub cb_Resource {
        $counter_Resource++;
}

sub cb_Project {
        my ($t, $project) = @_;

        my $projectID = $project->att('projectID');
        my $name      = $project->att('name');

        $counter_Project++;
        push @projects, { projectID => $projectID,
                          name      => $name };
}

sub cb_CustomInformation {
        $counter_CustomInformation++;
}

use XOG::Cargo::Test::QA;
use XOG::Cargo::Test::PS;
use XOG::Cargo::Test::TJ;

sub prepare_srcdir {
        my $srcdir = tempdir( CLEANUP => 1 );

        my $file_QA = "$srcdir/QA.xml";
        my $file_PS = "$srcdir/PS.xml";
        my $file_TJ = "$srcdir/TJ.xml";

        open TESTDATA, ">", $file_QA or die "Can not write to $file_QA";
        print TESTDATA $_ while <XOG::Cargo::Test::QA::DATA>;
        close TESTDATA;

        open TESTDATA, ">", $file_PS or die "Can not write to $file_PS";
        print TESTDATA $_ while <XOG::Cargo::Test::PS::DATA>;
        close TESTDATA;

        open TESTDATA, ">", $file_TJ or die "Can not write to $file_TJ";
        print TESTDATA $_ while <XOG::Cargo::Test::TJ::DATA>;
        close TESTDATA;

        return $srcdir;
}

sub execute {
        my $srcdir = prepare_srcdir;
        my $tmpdir = tempdir( CLEANUP => 1 );
        my $out_file = "$tmpdir/tmp_OUTFILE.xml";
        my $merger = Clarity::XOG::Merge->new( files => ["$srcdir/QA.xml",
                                                "$srcdir/PS.xml",
                                                "$srcdir/TJ.xml"],
                                      out_file => $out_file
                                    );
        $merger->Main;
        my $twig= XML::Twig->new ( twig_handlers => {
                                                     Project           => \&cb_Project,
                                                     Resource          => \&cb_Resource,
                                                     CustomInformation => \&cb_CustomInformation,
                                                    },
                         );
        $twig->parsefile( $out_file );
        is($counter_Resource, 14, "count result Resource elements");

        my @expected_projects = ( { projectID => "PRJ-300330", name      => "KRAM Testing" },
                                  { projectID => "PRJ-200220", name      => "Turbo Basic" },
                                  { projectID => "PRJ-100224", name      => "Eidolon" },
                                  { projectID => "PRJ-100222", name      => "International Karate" },
                                  { projectID => "PRJ-100223", name      => "Birne" }, );

        is($counter_Project, 5, "count result Project elements");
        cmp_bag(\@projects, \@expected_projects, "expected project elements");

        is($counter_CustomInformation, $counter_Project, "have as many CustomInformation as Project elements");
        done_testing();
}

1;

