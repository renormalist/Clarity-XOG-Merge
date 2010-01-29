#! /usr/bin/env perl

use strict;
use warnings;

use XOG::Merge;
use Test::More;

ok(1, "before");

my $merger = XOG::Merge->new (files => ['t/QA.xml', 't/PS.xml', 't/TJ.xml']);
$merger->Main;

ok(1, "after");

done_testing();
