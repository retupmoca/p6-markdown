use Text::Markdown::Document;
use Text::Markdown::to::HTML;

# wrapper/utility class (mostly for easy no-argument .render
# as well as compatability with masak's Text::Markdown)
class Text::Markdown {
    has $.document;

    multi method new($text) {
        self.bless(:document(Text::Markdown::Document.new($text)));
    }

    multi method render($class) {
        $.document.render($class);
    }

    multi method render() {
        $.document.render(Text::Markdown::to::HTML);
    }

    method to_html { self.render }
    method to-html { self.render }

    method Str {
        $.document.Str;
    }
}

our sub parse-markdown($text) is export {
    Text::Markdown.new($text);
}

our sub parse-markdown-from-file(Str $filename) is export {
  die "Can't locate $filename !" unless $filename.IO ~~ :e;

  my Str $text = slurp $filename;
  Text::Markdown.new($text);
}

=begin pod

=head1 Name

C«Text::Markdown», a Markdown parsing module for Perl6.

[![Build Status](https://travis-ci.org/retupmoca/p6-markdown.svg?branch=master)](https://travis-ci.org/retupmoca/p6-markdown)

=head1 Synopsis

=begin code
use Text::Markdown;
# Using raw Markdown directly
my $md = Text::Markdown.new($raw-md);
say $md.render;

# Or alternatively
my $md = parse-markdown($raw-md);
say $md.to_html;

# Using file
use Text::Markdown;
my $md = parse-markdown-from-file($filename);
=end code

=head1 Description

This module parses Markdown (MD) and generates HTML from it. It can be used
to extract certain elements from a MD document or to generate other
kind of things.  

=head1 Installation

=head2 Using C«zef»

=for code
zef update && zef install Text::Markdown

=head2 Dependencies

This modules depends on 
L«C«HTML::Escape»|https://github.com/moznion/p6-HTML-Escape». Install
it locally with 

=for code
zef install HTML::Escape

=head1 Routines

=head2 Methods

The following methods can be invoked on a C«Text::Markdown» instance object:

=item C«render» - Render the Markdown text provided to the instance object during its construction.
=item C«to_html» - An alias for the C«render» method.
=item C«to-html» - Same as the C«to_html» method.

=head2 Subroutines

=item C«parse-markdown($text)» - Render the Markdown C«$text».
=item C«parse-markdown-from-file(Str $filename)» - Render the Markdown text in file C«$filename».
 
=head1 Who

Initial version by L«Andrew Egeler|https://github.com/retupmoca», with
extensive additions by L«JMERELO|https://github.com/JJ»
and L«Altai-man|https://github.com/Altai-man».

=head1 Want to lend a hand?

Check out the L«contributing guidelines|CONTRIBUTING.md». All
contributions are welcome, and will be addressed.

=head1 License

You can redistribute this module and/or modify it under the terms of the 
MIT License.
=end pod
