#!/usr/bin/perl
# Author:  Bart Trojanowski <bart@jukie.net>
# Website: http://www.jukie.net/~bart/blog/urxvt-url-yank
# License: GPLv2

use strict;
use warnings;

my $url_matcher = qr{(
        (?:https?://|ftp://|news://|mailto:|file://|www\.)[ab-zA-Z0-9\-\@;\/?:&=%\$_.+!*\x27(),~#]+
        [ab-zA-Z0-9\-\@;\/?&=%\$_+!*\x27()~]   # exclude some trailing characters (heuristic)
)}x;


sub on_start {
    my ($term) = @_;

    $term->{have_Clipboard} = eval { require Clipboard; };
    if ($term->{have_Clipboard}) {
        import Clipboard;
    }

	eval { require Regexp::Common::URI };
	if(!$@) {
		require Regexp::Common;
		Regexp::Common->import('URI');

		$url_matcher = $Regexp::Common::RE{URI}{HTTP};
	}

    $term->{browser} = $term->x_resource ("urlLauncher") || "x-www-browser";

    ()
}

sub on_line_update {
    my ($term, $row) = @_;

    # Fetch the line that has changed.
    my $line = $term->line($row);
    my $text = $line->t;

    # Find and underline URLs.
    while ($text =~ /($url_matcher)/g) {
        my $url = $1;
        my $rend = $line->r;

        # Mark all characters as underlined. we _must_ not toggle underline, as
        # we might get called on an already-marked URL.
        my $underlineURLs = $term->x_resource ('underlineURLs') || 'false';
        if($underlineURLs eq 'true') {
			my ($first, $last) = ($-[1], $+[1] - 1);

			--$last if $url =~ s/["']$//;

            $_ |= urxvt::RS_Uline for @{$rend}[$first .. $last];

            $line->r($rend);
        }
    }

    ()
}

sub on_button_release {
    my ($term, $event) = @_;

    my $mask = $term->ModLevel3Mask | $term->ModMetaMask
    | urxvt::ShiftMask | urxvt::ControlMask;

    if ($event->{button} == 2 && ($event->{state} & $mask) == 0) {
        my $row = $event->{row};
        my $col = $event->{col};

        my $line = $term->line ($row);
        my $text = $line->t;

        while ($text =~ /($url_matcher)/g) {
            my ($url, $first, $last) = ($1, $-[1], $+[1]);

            if($first <= $col && $last >= $col) {
                $url =~ s/["']$//;
                $term->exec_async($term->{browser}, $url);
                return 1;
            }
        }
    }

    ()
}


my $mark_mode_active = 0;
my %mod = ( 'control' => 0, 'shift' => 0 );
my $url_selected = -1;
my @url_db = ();


sub do_scan_for_urls {
    my ($term) = @_;

    @url_db = ();

    my $row_start = $term->top_row;
    my $row_end = $term->nrow;

	for my $row ($row_start .. $row_end) {

        # Fetch the line that has changed.
        my $line = $term->line ($row);
        my $text = $line->t;

        # Find all urls (if any).
        while ($text =~ /($url_matcher)/g) {
            my $rend = $line->r;

			my ($url, $first, $last) = ($1, $-[1], $+[1] - 1);

			--$last if $url =~ s/["']$//;

            my %h = (
				row => $row,
				col_from => $first,
				col_to => $last,
				url => $url,
			);
				
			push @url_db, \%h;
        }
    }

    # 0 for none, positive count otherwise
    return $#url_db + 1;
}


sub on_user_command {
    my ($term, $cmd) = @_;

	activate_mark_mode($term) if $cmd eq 'mark-yank-urls:activate_mark_mode';

    ()
}

sub on_key_press {
    my ($term, $event, $keysym, $octets) = @_;

    if ($keysym == 65507) {                     # <control>
        $mod{control} = 1;

    } elsif ($keysym == 65505) {                # <shift>
        $mod{shift} = 1;

    }

    # Ignore all input when we are active.
    $mark_mode_active && return 1;

    ()
}

sub on_key_release {
    my ($term, $event, $keysym, $octets) = @_;

    if ($mark_mode_active) {
        my $ch = chr($keysym);

        if ($keysym == 65307) {                     # <esc>
            deactivate_mark_mode ($term);
            return 1;

        } elsif ($keysym == 65293) {                # <enter>
            my $url = get_active_url($term);
            $term->exec_async($term->{browser}, $url);
            deactivate_mark_mode ($term);
            return 1;

        } elsif ($keysym == 65507) {                # <control>
            $mod{control} = 0;
            return 1;

        } elsif ($keysym == 65505) {                # <shift>
            $mod{shift} = 0;
            return 1;

        } elsif ($mod{control} && (($ch eq 'n') || ($ch eq 'p'))) {
                                                    # ^n and ^p to cycle list
            my $dir = ($ch eq 'n') ? 1 : -1;
            move_highlight ($term, $dir);

        } elsif ($ch eq 'y') {                      # y
            do_copy ($term);
            deactivate_mark_mode ($term);
            return 1;

        }

        return 1;
    }

    ()
}

sub get_active_url {
    my ($term) = @_;
    my $max = $#url_db + 1;

    return if $url_selected < 0 || $url_selected >= $max;
    return if not defined $url_db[$url_selected];
    my $o = $url_db[$url_selected];
    my %h = %$o;

    return $h{url};
}

sub do_copy {
    my ($term) = @_;

    my $text = get_active_url ($term);

    if ($term->{have_Clipboard}) {
        Clipboard->copy($text);
    } else {
        $text =~ s/\(["|><&()]\)/\\$1/;
        system ("echo -n \"$text\" | xclip -i");
    }
}

sub move_highlight {
    my ($term, $dir) = @_;
    my $max = $#url_db + 1;

    do_highlight ($term, 0);
    
    $url_selected = ($max + $url_selected + $dir) % $max;
        
    do_highlight ($term, 1);

    $term->want_refresh;
}

sub do_highlight {
    my ($term, $enable) = @_;
    my $max = $#url_db + 1;

    return if $url_selected < 0 || $url_selected >= $max;
    return if not defined $url_db[$url_selected];

    my $o = $url_db[$url_selected];
    my %h = %$o;

    my $row = $h{row};
    my $line = $term->line ($row);
    my $text = $line->t;
    my $rend = $line->r;

    if ($enable) {
        $_ |= urxvt::RS_RVid
        for @{$rend}[ $h{col_from} .. $h{col_to}];

        # make it visible
        $term->view_start ( $row < 0 ? $row : 0 );

    } else {
        $_ &= ~urxvt::RS_RVid
        for @{$rend}[ $h{col_from} .. $h{col_to}];
    }

    $line->r ($rend);
}

sub activate_mark_mode {
    my ($term) = @_;

    if ($mark_mode_active) {

        move_highlight ($term, -1);

    } elsif ( do_scan_for_urls ($term) ) {

        $term->{save_view_start} = $term->view_start;

        move_highlight ($term, 0);

        $mark_mode_active=1 if ($url_selected > -1);
    }
}

sub deactivate_mark_mode {
    my ($term) = @_;

    do_highlight ($term, 0);

    $mark_mode_active = 0;
    $url_selected = -1;

    $term->view_start ($term->{save_view_start});
    $term->want_refresh;
}

# vim: set et ts=4 sw=4:
