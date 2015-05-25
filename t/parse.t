use v6;
use Text::Markdown;
use Test;

plan *;

my $text = q:to/TEXT/;
## Markdown Test ##

This is a simple markdown document.

It has two
paragraphs.
TEXT

my $document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 3, 'has correct number of items';

ok $document.items[0] ~~ Text::Markdown::Heading, 'first element is a header';
is $document.items[0].text, 'Markdown Test', '...with the right data';
is $document.items[0].level, 2, '...and the right heading level';

ok $document.items[1] ~~ Text::Markdown::Paragraph, 'second element is a paragraph';
is $document.items[1].items[0], 'This is a simple markdown document.'
   , '...with the right data';

ok $document.items[2] ~~ Text::Markdown::Paragraph, 'third element is a paragraph';
is $document.items[2].items[0], 'It has two paragraphs.'
   , '...with the right data';

$text = q:to/TEXT/;
 -  List One
 -  List Two

> blockquote
> fun

    code
    block

TEXT

$document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 3, 'has correct number of items';

ok $document.items[0] ~~ Text::Markdown::List, 'first element is a list';
ok $document.items[1] ~~ Text::Markdown::Blockquote, 'second element is a blockquote';
ok $document.items[2] ~~ Text::Markdown::CodeBlock, 'third element is a code block';
