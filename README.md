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

- Note: WikinewsSpam.pm is a custom-made module to report a recent review queue submissions for Wikinews. You will normally not need it.
- WikiLinker.pm automatically parses [[]] and {{}} links and returns a list of full https URLs.

---------------
1) Edit bot.pl to specify nick and network.
2) Edit WikinewsSpam.pm file top to specify time (if you load this module).
3) perl -Ilib bot.pl 

--------------
When making changes to the parser in lib/, make sure all tests pass.
prove -Ilib -vm t/WikiLinkParser.pm
