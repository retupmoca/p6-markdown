use v6;
use Text::Markdown::Document;
use Test;

plan 2;

my $text = 'This text includes escapes: \* \# \_';

my $document = Text::Markdown::Document.new($text);
ok $document ~~ Text::Markdown::Document, 'Able to parse';
ok $document.items[0] ~~ Text::Markdown::Paragraph,
        'second element is a paragraph';
say $document.raku;
