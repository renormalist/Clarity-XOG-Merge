package XOG::Command::commands;

use strict;
use warnings;

use XOG -command;

sub abstract { "list the application's commands" }

sub description {
        "This is a Clarity XOG utility. Its primary usecase is
merging project files. See 'xogtool help merge' for more
details."
}

*execute = *App::Cmd::Command::commands::execute;
*sort_commands = *App::Cmd::Command::commands::sort_commands;

1;

