#!/usr/local/bin/perl
#
# Copyright (C) 2013, 2014 Svetlana Tkachenko
#
#    This file is part of gpy.
#
#    gpy is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    gpy is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with gpy.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Bot::BasicBot::Pluggable;
print <<HEREDOC

    gpy is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gpy is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with gpy.  If not, see <http://www.gnu.org/licenses/>.

HEREDOC
    ;

my $bot = Bot::BasicBot::Pluggable->new(
 
                    channels => ["#wikinews", "#wikinews-en", "#wikinews-ru", "#wikipedia-ru", "#wikinews-ko"],
#                    channels => ["#wikinews-ru"],
                    server   => "irc.gnu.org",
                    port     => "6667",
 
                    nick     => "gpy",
                    altnicks => ["pbot", "pluggable"],
                    username => "bot",
                    name     => "bot http://repo.or.cz/w/gpy.git",
 
              );

$bot->load('WikiLinker');
$bot->load('WikinewsSpam');
$bot->load('RSS3');
$bot->run();

#_ _END_ _

