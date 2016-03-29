use v6;

use Test;

use lib 'lib';
use Text::Markdown;

plan 2;

my Str $filename = 't/text.md';
my $md = parse-markdown-from-file($filename);

ok $md ~~ Text::Markdown;
isa-ok $md, 'Text::Markdown';
