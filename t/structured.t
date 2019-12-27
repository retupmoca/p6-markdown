use Text::Markdown;
use Test;

my $text = q:to/TEXT/;
# Tuna risotto

A relatively simple version of this rich, creamy dish of Italian origin.

## Ingredients (for 4 persons)

* 500g tuna
* 250g rice
* Half an onion
* 250g cheese (parmegiano reggiano or granapadano, or manchego)
* Extra virgin olive oil
* 4 cloves garlic
TEXT

my $md = parse-markdown($text);
isa-ok( $md, Text::Markdown, "Instantiation OK");
isa-ok( $md.document.items[2], Text::Markdown::Heading, "Second level OK");
is( $md.document.items[2].level, 2, "Level heading OK");
isa-ok( $md.document.items[3], Text::Markdown::List, "Third object is a list");
is( $md.document.items[3].items.elems, 6, "List has the correct length");

$text = q:to/TEXT/;
* a list item
TEXT

$md = parse-markdown( $text );
is( $md.document.items.first.items.elems, 1, "There's one element in the list");

done-testing;
