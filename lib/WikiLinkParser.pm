#!/usr/bin/perl
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


package WikiLinkParser;

use MediaWiki::API;
use strict;
use warnings;
use HTML::TreeBuilder 5 -weak;
use URI::Escape;
use Data::Dumper;

=head2 get_url_by_text

=head3 Input

- a string of the wiki text, $wiki_text
- a mediawiki api object, $mw

=cut

sub get_urls_by_text{
    my $self = shift;
    my $text = shift;
    my $mw = shift;
    my @urls = ();
    # wiki text to html
    while ($text =~ m{\[\[(.*?)\]\]}g) {
        push @urls, $self->_parse($1,$mw);
    }
    while ($text =~ m<{{(.*?)[\||}}]>g) {
        push @urls, $self->_parse("Template:$1",$mw);
    }
    return \@urls;
}

sub uri_unescape_utf8 { my ($str) = @_; $str = uri_unescape $str; utf8::decode $str; $str }

sub _parse{
    my $self = shift;
    my $text = shift;
    my $mw = shift;
    my $info_ref = $mw->api ( {
        action      => 'parse',
        prop        => 'text',
        text        => "{{fullurl:$text}}",
    } ) or die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
    my $html = $info_ref->{parse}{text}{'*'};
    # parse html
    my $tree = HTML::TreeBuilder->new_from_content($html);
    my $url = uri_unescape_utf8 ('https:'.$tree->look_down('_tag','p')->content_array_ref->[0]);
    if ($url =~ m{^https:\/\/}) {return $url;}
}

1;

