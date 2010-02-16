use inc::Module::Install;

name     'XOG-Merge';
all_from 'lib/XOG/Merge.pm';
author   'Steffen Schwigon <ss5@renormalist.net>';
license  'perl';

author_requires 'Module::Install::WriteAll';

requires 'Test::More'; # [sic]
requires 'Test::Deep'; # [sic]
requires 'File::Temp';
requires 'File::ShareDir';
requires 'File::Find::Rule';
requires 'Data::Dumper';
requires 'XML::Twig';
requires 'Moose';
requires 'App::Cmd';

par_base "SCHWIGON";

install_script 'xogtool';

auto_install;

WriteAll;
