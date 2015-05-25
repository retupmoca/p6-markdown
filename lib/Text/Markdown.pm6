class Text::Markdown::Paragraph {
    has @.items;

    # TODO: wrapping?
    method Str { @.items>>.Str.join ~ "\n\n" }
}

class Text::Markdown::Code {
    has $.text;

    # TODO: handle case where $.text contains '`'
    method Str { '`' ~ $.text ~ '`' }
}

class Text::Markdown::CodeBlock {
    has $.text;

    method Str {
        my $ret;
        for $.text.lines {
            $ret ~= '    ' ~ $_;
        }
        $ret ~ "\n\n";
    }
}

class Text::Markdown::List {
    has $.numbered;
    has @.items;

    method Str {
        my $ret;
        for @.items.kv -> $i, $_ {
            my $text = $_.Str;
            for $text.lines.kv -> $j, $l {
                if $j {
                    $ret ~= '    ' ~ $l;
                }
                else {
                    if $.numbered {
                        $ret ~= ' ' ~ ($i + 1) ~ '. ' ~ $l;
                    }
                    else {
                        $ret ~= ' -  ' ~ $l;
                    }
                }
            }
            $ret ~= "\n\n";
        }
    }
}

class Text::Markdown::Heading {
    has $.text;
    has $.level;

    method Str { ("#" x $.level) ~ ' ' ~ $.text ~ "\n\n" }
}

class Text::Markdown::Rule { method Str { "---\n\n" } }

class Text::Markdown::Blockquote {
    has @.items;

    method Str {
        die;
    }
}

class Text::Markdown::Link {
}

class Text::Markdown::Image {
}

class Text::Markdown::Emphasis {
}

class Text::Markdown::Document {
    has @.items;

    method Str { @.items>>.Str.join }

    method item-from-chunk($chunk is rw) {
        if $chunk ~~ /^(\#+)/ {
            my $level = $0.chars;
            $chunk ~~ s/^\#+\s+//;
            $chunk ~~ s/\s+\#+$//;
            return Text::Markdown::Heading.new(:text($chunk),
                                               :level($level));
        }
        elsif all($chunk.lines.map({ so $_ ~~ /^\s\s\s\s/ })) {
            return Text::Markdown::CodeBlock.new(:text($chunk));
        }
        elsif all($chunk.lines.map({ so $_ ~~ /^\>\s/ })) {
            $chunk ~~ s/^\>\s+//;
            return Text::Markdown::Blockquote.new(
                                      :items(self.new($chunk).items));
        }
        elsif $chunk {
            $chunk ~~ s:g/\n/ /;
            return Text::Markdown::Paragraph.new(:items($chunk));
        }
    }

    multi method new($text) {
        my @lines = $text.lines;

        my $chunk = '';
        my @items;
        my $in-list;
        my @list-items;
        for @lines -> $l {
            if !$in-list && $l ~~ /^\s*$/ {
                @items.push(self.item-from-chunk($chunk));
                $chunk = '';
            }
            else {
                if $l ~~ /^\s+\-\s/ {
                    $in-list = True;
                    if $chunk {
                        $chunk ~~ s/^\s+\-\s+//;
                        @list-items.push(self.new($chunk));
                        $chunk = '';
                    }
                }
                elsif $in-list && $l ~~ /^\S/ {
                    $in-list = False;
                    $chunk ~~ s/^\s+\-\s+//;
                    @list-items.push(self.new($chunk));
                    $chunk = '';
                    @items.push(Text::Markdown::List.new(:items(@list-items)));
                    @list-items = ();
                }
                $chunk ~= "\n" if $chunk;
                $chunk ~= $l;
            }
        }
        @items.push(self.item-from-chunk($chunk)) if $chunk && !$in-list;
        $chunk ~~ s/^\s+\-\s+//;
        @list-items.push(self.new($chunk)) if $chunk && $in-list;
        @items.push(Text::Markdown::List.new(:items(@list-items))) if @list-items;

        self.bless(:@items);
    }
}
