#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'XOG' );
}

diag( "Testing XOG $XOG::VERSION, Perl $], $^X" );
