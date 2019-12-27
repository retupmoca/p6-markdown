use Text::Markdown;


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