use Text::Markdown;

class Text::Markdown::to::HTML {
    multi method render(Text::Markdown::Document $d) {
        my $ret;
        for $d.items {
            $ret ~= self.render($_);
        }
        $ret;
    }

    multi method render(Text::Markdown::Paragraph $p) {
        my $ret;
        for $p.items {
            $ret ~= self.render($_);
        }
        '<p>' ~ $ret ~ '</p>';
    }

    multi method render(Str $s) { $s }

    multi method render(Text::Markdown::Code $c) {
        '<code>' ~ $c.text ~ '</code>';
    }

    multi method render(Text::Markdown::CodeBlock $c) {
        '<pre><code>' ~ $c.text ~ '</code></pre>';
    }

    multi method render(Text::Markdown::List $l) {
        my $ret;
        for $l.items {
            $ret ~= '<li>' ~ self.render($_) ~ '</li>';
        }
        if $l.numbered {
            '<ol>' ~ $ret ~ '</ol>';
        }
        else {
            '<ul>' ~ $ret ~ '</ul>';
        }
    }

    multi method render(Text::Markdown::Heading $h) {
        '<h' ~ $h.level ~ '>' ~ $h.text ~ '</h' ~ $h.level ~ '>';
    }

    multi method render(Text::Markdown::Rule $r) { '<hr>' }

    multi method render(Text::Markdown::Blockquote $p) {
        my $ret;
        for $p.items {
            $ret ~= self.render($_);
        }
        '<blockquote>' ~ $ret ~ '</blockquote>';
    }

    multi method render(Text::Markdown::Link $r) { ... }
    multi method render(Text::Markdown::Image $r) { ... }
    multi method render(Text::Markdown::Emphasis $r) { ... }
}
