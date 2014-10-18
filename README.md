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

--------------
<Svetlana> gpy: rss list
<gpy> Svetlana: [Опубликовано] - https://ru.wikinews.org/w/index.php?title=Special:NewsFeed&feed=atom&categories=%D0%9E%D0%BF%D1%83%D0%B1%D0%BB%D0%B8%D0%BA%D0%BE%D0%B2%D0%B0%D0%BD%D0%BE&namespace=0&count=30&ordermethod=categoryadd&stablepagesonly=no
<gpy> ..[Редактируется] - https://ru.wikinews.org/w/index.php?title=Special:NewsFeed&feed=atom&categories=%D0%A0%D0%B5%D0%B4%D0%B0%D0%BA%D1%82%D0%B8%D1%80%D1%83%D0%B5%D1%82%D1%81%D1%8F&namespace=0&count=30&ordermethod=categoryadd&stablepagesonly=no
<gpy> ..[Рецензия] - https://ru.wikinews.org/w/index.php?title=Special:NewsFeed&feed=atom&categories=%D0%A0%D0%B5%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F&namespace=0&count=30&ordermethod=categoryadd&stablepagesonly=no

--------------
