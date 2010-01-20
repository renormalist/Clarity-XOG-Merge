use inc::Module::Install;

name     'XOG-Merge';
all_from 'lib/XOG/Merge.pm';
author   'Steffen Schwigon <ss5@renormalist.net>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

