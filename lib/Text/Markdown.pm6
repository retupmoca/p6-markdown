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


=head2 Example Usage

=begin pod

    use Text::Markdown;
    my $md = Text::Markdown.new($raw-md);
    say $md.render;

or

    use Text::Markdown;
    my $md = parse-markdown($raw-md);
    say $md.to_html;

or, using a file :

    use Text::Markdown;
    my $md = parse-markdown-from-file($filename);

=end pod
