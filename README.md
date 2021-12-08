Name
====

`Text::Markdown`, a Markdown parsing module for Perl6.

Synopsis
========

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

Description
===========

This module parses Markdown (MD) and generates HTML from it. It can be used to extract certain elements from a MD document or to generate other kind of things. 

Installation
============

Using `zef`
-----------

    zef update && zef install Text::Markdown

Dependencies
------------

This modules depends on [`HTML::Escape`](https://github.com/moznion/p6-HTML-Escape). Install it locally with 

    zef install HTML::Escape

Routines
========

Methods
-------

The following methods can be invoked on a `Text::Markdown` instance object:

  * `render` - Render the Markdown text provided to the instance object during its construction.

  * `to_html` - An alias for the `render` method.

  * `to-html` - Same as the `to_html` method.

Subroutines
-----------

  * `parse-markdown($text)` - Render the Markdown `$text`.

  * `parse-markdown-from-file(Str $filename)` - Render the Markdown text in file `$filename`.

Who
===

Initial version by [Andrew Egeler](https://github.com/retupmoca), with 
extensive additions by [JMERELO](https://github.com/JJ) and [Altai-man]
(https://github.com/Altai-man). Some help from [Luis Uceta](https://github.com/uzluisf)

Want to lend a hand?
====================

Check out the [contributing guidelines](CONTRIBUTING.md). All contributions are welcome, and will be addressed.

License
=======

You can redistribute this module and/or modify it under the terms of the MIT License.

