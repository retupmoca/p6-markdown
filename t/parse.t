use v6;
use Text::Markdown::Document;
use Test;

plan 159;

my $text = q:to/TEXT/;
## Markdown Test ##

This is a simple markdown document.

---

It has two
paragraphs.
TEXT

my $document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 4, 'has correct number of items';

ok $document.items[0] ~~ Text::Markdown::Heading, 'first element is a header';
is $document.items[0].text, 'Markdown Test', '...with the right data';
is $document.items[0].level, 2, '...and the right heading level';

ok $document.items[1] ~~ Text::Markdown::Paragraph, 'second element is a paragraph';
is $document.items[1].items[0], 'This is a simple markdown document.'
   , '...with the right data';

ok $document.items[2] ~~ Text::Markdown::Rule, 'third element is a rule';

ok $document.items[3] ~~ Text::Markdown::Paragraph, 'fourth element is a paragraph';
is $document.items[3].items[0], 'It has two paragraphs.'
   , '...with the right data';

$text = q:to/TEXT/;
 -  List One
 -  List Two

> blockquote
> fun

    code
    block

 -  Block List One

 -  Block List Two

 1. ol One
 2. ol Two

TEXT

$document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 5, 'has correct number of items';

my $li = $document.items[0];
ok $li ~~ Text::Markdown::List, 'first element is a list';
ok !$li.numbered, '...that is unordered';
ok $li.items == 2, '...with two items';

# not sure how I want to represent simple elements, since I need to support
# inline...
#
# maybe just a list of arrays? ::ListItem?
# (would also be good to get ::Document out of the list)

#ok $li.items[0] ~~ Str, '...with simple elements';
#is $li.items[1], 'List Two', '...and correct data';

my $bi = $document.items[1];
ok $bi ~~ Text::Markdown::Blockquote, 'second element is a blockquote';
ok $bi.items == 1, '...with one item';
ok $bi.items[0] ~~ Text::Markdown::Paragraph, '...which is a paragraph';
is $bi.items[0].items[0], 'blockquote fun', '...with the correct data';

my $ci = $document.items[2];
ok $ci ~~ Text::Markdown::CodeBlock, 'third element is a code block';
is $ci.text, "code\nblock", '...with correct data';

$li = $document.items[3];
ok $li ~~ Text::Markdown::List, 'fourth element is a list';
ok $li.items == 2, '...with two items';
$li = $li.items[1];
ok $li ~~ Text::Markdown::Document, '...with complex elements';
is $li.items[0].items[0], 'Block List Two', '...with correct data';

$li = $document.items[4];
ok $li ~~ Text::Markdown::List, 'fifth element is a list';
ok $li.numbered, '...which is ordered';
ok $li.items == 2, '...with two items';

$text = q:to/TEXT/;
This is a *paragraph* with **many** `different` ``inline` elements``.
[Links](http://google.com), for [example][], as well as ![Images](/bad/path.jpg)
(including ![Reference][] style) <http://google.com>

[example]: http://example.com
[Reference]: /another/bad/image.jpg
TEXT

$document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 1, 'has correct number of items';
my $p = $document.items[0];
ok $p ~~ Text::Markdown::Paragraph, '...which is a single paragraph';

is $p.items.elems, 18, 'with the right number of sub-items';

is $p.items[0], 'This is a ', 'first text chunk';

ok $p.items[1] ~~ Text::Markdown::Emphasis, 'first emphasis chunk';
is $p.items[1].level, 1, '...with correct emphasis';
is $p.items[1].text, 'paragraph', '...and text';

is $p.items[2], ' with ', 'second text chunk';

ok $p.items[3] ~~ Text::Markdown::Emphasis, 'second emphasis chunk';
is $p.items[3].level, 2, '...with correct emphasis';
is $p.items[3].text, 'many', '...and text';

is $p.items[4], ' ', 'third text chunk';

ok $p.items[5] ~~ Text::Markdown::Code, 'first code chunk';
is $p.items[5].text, 'different', '...with correct text';

is $p.items[6], ' ', 'fourth text chunk';

ok $p.items[7] ~~ Text::Markdown::Code, 'second code chunk';
is $p.items[7].text, 'inline` elements', '...with correct text';

is $p.items[8], '. ', 'fifth text chunk';

ok $p.items[9] ~~ Text::Markdown::Link, 'first link';
is $p.items[9].url, 'http://google.com', '...with correct link';
is $p.items[9].text, 'Links', '...with correct text';
ok !$p.items[9].ref, '...with correct ref';

is $p.items[10], ', for ', 'sixth text chunk';

ok $p.items[11] ~~ Text::Markdown::Link, 'second link';
ok !$p.items[11].url, '...with correct link';
is $p.items[11].text, 'example', '...with correct text';
is $p.items[11].ref, 'example', '...with correct ref';

is $p.items[12], ', as well as ', 'seventh text chunk';

ok $p.items[13] ~~ Text::Markdown::Image, 'first image';
is $p.items[13].url, '/bad/path.jpg', '...with correct link';
is $p.items[13].text, 'Images', '...with correct text';
ok !$p.items[13].ref, '...with correct ref';

is $p.items[14], ' (including ', 'eighth text chunk';

ok $p.items[15] ~~ Text::Markdown::Image, 'second image';
ok !$p.items[15].url, '...with correct link';
is $p.items[15].text, 'Reference', '...with correct text';
is $p.items[15].ref, 'Reference', '...with correct ref';

is $p.items[16], ' style) ', 'ninth text chunk';

ok $p.items[17] ~~ Text::Markdown::Link, 'third link';
is $p.items[17].url, 'http://google.com', '...with correct link';
is $p.items[17].text, 'http://google.com', '...with correct text';
ok !$p.items[17].ref, '...with correct ref';

is $document.references.elems, 2, 'got correct reference count';
is $document.references<example>, 'http://example.com', 'first ref';
is $document.references<Reference>, '/another/bad/image.jpg', 'second ref';

$text = q:to/TEXT/;
This one tests links like <http://example.com> or <http://a> or
<http://a/><https://b>, as well as mail addresses like
<example@example.com> or <camelia.is.the.best@perl6.org>.

Finally, we test inline html elements like <span class="a"><b>example</b></span>
or block elements like

<table>
  <tr>
    <td>A</td><td>B</td>
  </tr>
  <tr>
    <td>X</td>
    <td>Y</td>
  </tr>
</table>
TEXT

$document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 3, 'has correct number of items';
$p = $document.items[0];
ok $p ~~ Text::Markdown::Paragraph, 'first block is a paragraph';
is $p.items.elems, 12, 'correct number of elements in paragraph';
is $p.items[0], 'This one tests links like ', 'starts with some text';
ok $p.items[1] ~~ Text::Markdown::Link, 'inline link';
is $p.items[1].url, 'http://example.com', 'inline link has correct url';
is $p.items[1].text, 'http://example.com', 'inline link has correct text';
ok !$p.items[1].ref, 'inline link has no ref';
is $p.items[2], ' or ', 'separator word between links.';
ok $p.items[3] ~~ Text::Markdown::Link, 'inline link no domain name';
is $p.items[3].url, 'http://a', 'inline link that is not a domain name has correct url';
is $p.items[3].text, 'http://a', 'inline link that is not a domain name has correct text';
ok !$p.items[3].ref, 'inline link has no ref';
is $p.items[4], ' or ', 'separator word between links.';
ok $p.items[5] ~~ Text::Markdown::Link, 'inline link no domain name';
is $p.items[5].url, 'http://a/', 'inline link that is not a domain name has correct url';
is $p.items[5].text, 'http://a/', 'inline link that is not a domain name has correct text';
ok !$p.items[5].ref, 'inline link has no ref';
ok $p.items[6] ~~ Text::Markdown::Link, 'inline link no domain name';
is $p.items[6].url, 'https://b', 'inline link that is not a domain name has correct url';
is $p.items[6].text, 'https://b', 'inline link that is not a domain name has correct text';
ok !$p.items[6].ref, 'inline link has no ref';
is $p.items[7], ', as well as mail addresses like ', 'separator text between links.';
ok $p.items[8] ~~ Text::Markdown::EmailLink, 'inline link to mail address';
is $p.items[8].url, 'example@example.com', 'email link contains correct url';
is $p.items[9], ' or ', 'separator text between links.';
ok $p.items[10] ~~ Text::Markdown::EmailLink, 'inline link to mail address';
is $p.items[10].url, 'camelia.is.the.best@perl6.org', 'email link contains correct url';
is $p.items[11], '.', 'text at end of paragraph';

$p = $document.items[1];
ok $p ~~ Text::Markdown::Paragraph, 'second block is a paragraph';
is $p.items.elems, 7, 'second paragraph contains correct number of elements';
is $p.items[0], 'Finally, we test inline html elements like ', 'text before html tags';
ok $p.items[1] ~~ Text::Markdown::HtmlTag, 'tags are parsed';
is $p.items[1].tag, '<span class="a">', 'tag content is correct';
ok $p.items[2] ~~ Text::Markdown::HtmlTag, 'tags are parsed';
is $p.items[2].tag, '<b>', 'tag content is correct';
is $p.items[3], 'example', 'text between tags';
ok $p.items[4] ~~ Text::Markdown::HtmlTag, 'tags are parsed';
is $p.items[4].tag, '</b>', 'tag content is correct';
ok $p.items[5] ~~ Text::Markdown::HtmlTag, 'tags are parsed';
is $p.items[5].tag, '</span>', 'tag content is correct';
is $p.items[6], ' or block elements like', 'text before html tags';

$p = $document.items[2];
is $p.items.elems, 26, 'correct number of elements in html block';
ok $p ~~ Text::Markdown::HtmlBlock, 'third block is an html block';
my %tags =
  0 => '<table>',
  2 => '<tr>',
  4 => '<td>',
  6 => '</td>',
  7 => '<td>',
  9 => '</td>',
  11 => '</tr>',
  13 => '<tr>',
  15 => '<td>',
  17 => '</td>',
  19 => '<td>',
  21 => '</td>',
  23 => '</tr>',
  25 => '</table>';
for %tags.kv -> $position, $value {
  ok $p.items[$position] ~~ Text::Markdown::HtmlTag, 'html tags parsed correctly';
  is $p.items[$position].tag, $value, 'html tag contents correct';
}
my %strings =
  5 => 'A',
  8 => 'B',
  16 => 'X',
  20 => 'Y';
for %strings.kv -> $position, $value {
  is $p.items[$position], $value, 'text parts in html block correct';
}
my @spaces = 1, 3, 10, 12, 14, 18, 22, 24;
for @spaces -> $position {
  ok $p.items[$position] ~~ /\s+/, 'white spaces detected correctly';
}

