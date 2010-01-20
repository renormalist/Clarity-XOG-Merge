#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'XOG::Merge' );
}

diag( "Testing XOG::Merge $XOG::Merge::VERSION, Perl $], $^X" );
