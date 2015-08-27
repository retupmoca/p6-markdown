use v6;
use Text::Markdown::Document;
use Test;

plan 74;

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
