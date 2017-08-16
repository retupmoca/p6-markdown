use v6;
use Text::Markdown::Document;
use Test;

plan 3;

my $text = q:to/TEXT/;
[`grep`](https://docs.perl6.org/routine/grep) is
one of them
TEXT

my $document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 1, 'has correct number of items';

my $p = $document.items[0];
ok $p ~~ Text::Markdown::Paragraph, 'It is a Paragraph';

dd $p.items;


