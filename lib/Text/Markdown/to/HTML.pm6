use HTML::Escape;
use Text::Markdown::Document;

class Text::Markdown::to::HTML {
    has $!document;

    multi method render(Text::Markdown::Document $d) {
        unless $!document {
            $!document = $d;
        }
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
        '<code>' ~ escape-html($c.text) ~ '</code>';
    }

    multi method render(Text::Markdown::CodeBlock $c) {
        my $lang-class = $c.lang ?? ' class="' ~ $c.lang ~ '"' !! '';
        "<pre><code{$lang-class}>" ~ escape-html($c.text) ~ '</code></pre>';
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

    multi method render(Text::Markdown::Link $r) {
        my $url = $r.url;
        unless $url {
            $url = $!document.references{$r.ref};
        }
        '<a href="' ~ $url ~ '">' ~ $r.text ~ '</a>';
    }

    multi method render(Text::Markdown::EmailLink $r) {
      '< href="mailto:' ~ $r.url ~ '">' ~ $r.url ~ '</a>';
    }

    multi method render(Text::Markdown::Image $r) {
        my $url = $r.url;
        unless $url {
            $url = $!document.references{$r.ref};
        }
        '<img src="' ~ $url ~ '" alt="' ~ $r.text ~ '" />';
    }
    multi method render(Text::Markdown::Emphasis $r) {
        if $r.level == 1 {
            '<em>' ~ $r.text ~ '</em>';
        }
        else {
            '<strong>' ~ $r.text ~ '</strong>';
        }
    }

    multi method render(Text::Markdown::HtmlBlock $r) {
      $r.items.map( -> $child { self.render($child) } ).join("");
    }

    multi method render(Text::Markdown::HtmlTag $r) {
      $r.tag;
    }

    multi method render(Seq $values) {
        $values.map({ self.render($_) }).join('');
    }
}
