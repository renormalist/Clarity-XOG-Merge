package XOG;
use App::Cmd::Setup -app;
our $VERSION = '1.01';

sub usage_desc { "xogtool <subcommand> [options]* [files]*" }
sub abstract { "*** ABSTRACT *** ABSTRACT *** Clarity XOG utility" }

sub default_command { "commands" }

sub _usage_text {
"xogtool <subcommand> [options]* [files]*

  This is a Clarity XOG tool.
  Its primary usecase is merging XOG project files.
  See 'xogtool help merge' for more details.
",
}

1;
