use inc::Module::Install;

name     'XOG';
all_from 'lib/XOG.pm';
author   'Steffen Schwigon <ss5@renormalist.net>';
license  'perl';

author_requires 'Module::Install::WriteAll';

requires 'Test::More'; # [sic, for selftest]
requires 'Test::Deep'; # [sic, for selftest]
requires 'File::Temp';
requires 'File::ShareDir';
requires 'File::Find::Rule';
requires 'Data::Dumper';
requires 'XML::Twig';
requires 'Moose';
requires 'App::Cmd';

#author_requires 'Module::Install::PAR';
#author_requires 'PAR::Packer';
#author_requires 'PAR::Dist';
#par_base "SCHWIGON";

install_script 'xogtool';

auto_install;

WriteAll;
