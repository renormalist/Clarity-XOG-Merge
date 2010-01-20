#! /usr/bin/env perl

use strict;
use warnings;

use XOG::Merge;
use Test::More;

ok(1, "affe");

my $merger = new XOG::Merge;
$merger->Main;

done_testing();
