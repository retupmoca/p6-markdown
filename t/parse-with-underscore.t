use v6;
use Text::Markdown::Document;
use Test;

plan 4;

my $text = q:to/TEXT/;
this character belongs to this
[category](https://en.wikipedia.org/wiki/Unicode_character_property#General_Category),
TEXT

my $document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
is $document.items.elems, 1, 'has correct number of items';

my $p = $document.items[0];
ok $p ~~ Text::Markdown::Paragraph, 'It is a Paragraph';

dd $p.items;

is $p.items.elems, 3, "Slurped link correctly";
			  
