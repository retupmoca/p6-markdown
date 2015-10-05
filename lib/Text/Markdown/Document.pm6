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
        ...;
    }
}

class Text::Markdown::Link {
    has $.url;
    has $.text;
    has $.ref;

    method Str {
        ...;
    }
}

class Text::Markdown::Image {
    has $.url;
    has $.text;
    has $.ref;

    method Str {
        ...;
    }
}

class Text::Markdown::Emphasis {
    has $.text;
    has $.level;

    method Str {
        ...;
    }
}

class Text::Markdown::Document {
    has @.items;
    has %.references;

    method Str { @.items>>.Str.join }

    multi method render($class) {
        my $c = $class;
        $c = $class.new unless defined($class);

        return $c.render(self);
    }

    method parse-inline($chunk) {
        my @ret = $chunk;
        my $changed = False;
        repeat {
            $changed = False;
            my @tmp = @ret;
            @ret = ();

            for @tmp -> $_ is rw {
                if $_ ~~ Str {
                    # regex stolen shamlessly from masak's Text::Markdown
                    if $_ ~~ s[ ('**'||'__') <?before \S> (.+?<[*_]>*) <?after \S> $0 (.*) ] = "" {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Emphasis.new(:text(~$1), :level(2)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    # regex stolen shamlessly from masak's Text::Markdown
                    elsif $_ ~~ s[ ('*'||'_') <?before \S> (.+?) <?after \S> $0 (.*) ] = "" {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Emphasis.new(:text(~$1), :level(1)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    # regex stolen shamlessly from masak's Text::Markdown
                    elsif $_ ~~ s/ ('`'+) (.+?) <!after '`'> $0 <!before '`'> (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Code.new(:text(~$1)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    elsif $_ ~~ s/ \! \[ (.+?) \] \( (.+?) \) (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Image.new(:text(~$0), :url(~$1)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    elsif $_ ~~ s/ \! \[ (.+?) \] \[ (.*?) \] (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Image.new(:text(~$0), :ref(~$1 || ~$0)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    elsif $_ ~~ s/ \[ (.+?) \] \( (.+?) \) (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Link.new(:text(~$0), :url(~$1)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    elsif $_ ~~ s/ \[ (.+?) \] \[ (.*?) \] (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Link.new(:text(~$0), :ref(~$1 || ~$0)));
                        @ret.push(~$2);
                        $changed = True;
                    }
                    elsif $_ ~~ s/ \< (.+?) \> (.*) // {
                        @ret.push($_);
                        @ret.push(Text::Markdown::Link.new(:text(~$0), :url(~$0)));
                        @ret.push(~$1);
                        $changed = True;
                    }
                    else {
                        @ret.push($_);
                    }
                }
                else {
                    @ret.push($_);
                }
            }

        } until !$changed;

        @ret.grep({ $_ });
    }

    method item-from-chunk($chunk is rw) {
        if $chunk ~~ /^(\#+)/ {
            my $level = $0.chars; $chunk ~~ s/^\#+\s+//;
            $chunk ~~ s/\s+\#+$//;
            return Text::Markdown::Heading.new(:text($chunk),
                                               :level($level));
        }
        elsif all($chunk.lines.map({ so $_ ~~ /^\h ** 4/ })) {
            $chunk ~~ s:g/^^\h ** 4//;
            return Text::Markdown::CodeBlock.new(:text($chunk));
        }
        elsif all($chunk.lines.map({ so $_ ~~ /^\>\s/ })) {
            $chunk ~~ s:g/^^\>\s+//;
            return Text::Markdown::Blockquote.new(
                                      :items(self.new($chunk).items));
        }
        elsif $chunk.lines == 1 && $chunk ~~ /^\-\-\-/ {
            return Text::Markdown::Rule.new;
        }
        elsif all($chunk.lines.map({ so $_ ~~ /^\[ .+? \]\: .+/ })) {
            for $chunk.lines {
                $_ ~~ /^\[ (.+?) \]\: \s* (.+)/;
                %!references{$0} = $1;
            }
            return ''
        }
        elsif $chunk {
            $chunk ~~ s:g/\n/ /;
            return Text::Markdown::Paragraph.new(:items(self.parse-inline($chunk)));
        }
    }

    multi method new($text) {
        self.bless(:$text);
    }

    submethod BUILD(:$text) {
        return unless $text;

        my @lines = $text.lines;

        my $chunk = '';
        my @items;
        my $in-list;
        my $list-ordered;
        my @list-items;
        for @lines -> $l {
            if !$in-list && $l ~~ /^\s*$/ {
                @items.push(self.item-from-chunk($chunk)) if $chunk.chars;
                $chunk = '';
            }
            else {
                if $l ~~ /^\s+\-\s/ {
                    if $in-list && $list-ordered {
                        $chunk ~~ s/^\s+\d+\.?\s+//;
                        @list-items.push(self.new($chunk));
                        $chunk = '';
                        @items.push(Text::Markdown::List.new(:items(@list-items), :numbered($list-ordered)));
                        @list-items = ();
                    }
                    $in-list = True;
                    $list-ordered = False;
                    if $chunk {
                        $chunk ~~ s/^\s+\-\s+//;
                        @list-items.push(self.new($chunk));
                        $chunk = '';
                    }
                }
                elsif $l ~~ /^\s+\d+\.?\s/ {
                    if $in-list && !$list-ordered {
                        $chunk ~~ s/^\s+\-\s+//;
                        @list-items.push(self.new($chunk));
                        $chunk = '';
                        @items.push(Text::Markdown::List.new(:items(@list-items), :numbered($list-ordered)));
                        @list-items = ();
                    }
                    $in-list = True;
                    $list-ordered = True;
                    if $chunk {
                        $chunk ~~ s/^\s+\d+\.?\s+//;
                        @list-items.push(self.new($chunk));
                        $chunk = '';
                    }
                }
                elsif $in-list && $l ~~ /^\S/ {
                    $in-list = False;
                    if $list-ordered {
                        $chunk ~~ s/^\s+\d+\.?\s+//;
                    }
                    else {
                        $chunk ~~ s/^\s+\-\s+//;
                    }
                    @list-items.push(self.new($chunk));
                    $chunk = '';
                    @items.push(Text::Markdown::List.new(:items(@list-items), :numbered($list-ordered)));
                    @list-items = ();
                }
                $chunk ~= "\n" if $chunk;
                $chunk ~= $l;
            }
        }
        @items.push(self.item-from-chunk($chunk)) if $chunk && !$in-list;
        if $list-ordered {
            $chunk ~~ s/^\s+\d+\.?\s+//;
        }
        else {
            $chunk ~~ s/^\s+\-\s+//;
        }
        @list-items.push(self.new($chunk)) if $chunk && $in-list;
        @items.push(Text::Markdown::List.new(:items(@list-items), :numbered($list-ordered))) if @list-items;

        @items .= grep({ $_ });

        @!items = @items;
        #self.bless(:@items);
    }
}
