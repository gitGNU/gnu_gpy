#!/usr/local/bin/perl
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
use WikiLinkParser;
use MediaWiki::API;
use Test::More;

my $url = 'https://en.wikinews.org';
my $mw = MediaWiki::API->new();
$mw->{config}->{api_url} = $url.'/w/api.php';

my $prefix = "$url/wiki";

is_deeply(
    WikiLinkParser->get_urls_by_text("[[Dog]]", $mw),
    ["$prefix/Dog"],
    'Gets url of a page'
);

is_deeply(
    WikiLinkParser->get_urls_by_text("{{sofixit}}", $mw),
    ["$prefix/Template:Sofixit"],
    'Gets url of a template'
);

is_deeply(
    WikiLinkParser->get_urls_by_text("{{sofixit|1|2=35}}", $mw),
    ["$prefix/Template:Sofixit"],
    'Gets url of a template with params'
);

is_deeply(
    WikiLinkParser->get_urls_by_text("[[Собака]]", $mw),
    ["$prefix/Собака"],
    'Gets URL of a unicode page name properly'
);

is_deeply(
    WikiLinkParser->get_urls_by_text("[[Собака#Что такое]]", $mw),
    ["$prefix/Собака#.C3.90.C2.A7.C3.91.C2.82.C3.90.C2.BE_.C3.91.C2.82.C3.90.C2.B0.C3.90.C2.BA.C3.90.C2.BE.C3.90.C2.B5"],
    'Gets URL of a unicode section name properly'
);

is_deeply(
    WikiLinkParser->get_urls_by_text("[[Dog#What is]]", $mw),
    ["$prefix/Dog#What_is"],
    'Gets a section name with spaces properly'
);
is_deeply(
    WikiLinkParser->get_urls_by_text("[[wikipedia:fr:Dog]]", $mw),
    ['https://en.wikipedia.org/wiki/fr:Dog'], # this forwards to fr.wp.org
    'Gets interwiki links properly'
);
is_deeply(
    WikiLinkParser->get_urls_by_text("[[{{Sofixit}}]]", $mw),
    ['', "$prefix/Template:Sofixit"],
    "Does not parse [[]]s with rubbish in them"
);

done_testing( 8 );
