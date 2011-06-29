#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Clarity::XOG' );
}

diag( "Testing XOG $Clarity::XOG::VERSION, Perl $], $^X" );
