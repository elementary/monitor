/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.LabelRoundy : Gtk.Box {
    public string title { get; construct; }

    public string text {
        set {
            val.label = value;
        }
    }

    public int width_chars {
        set {
            val.width_chars = value;
        }
    }

    private Gtk.Label val;

    public LabelRoundy (string title) {
        Object (title: title);
    }

    class construct {
        set_css_name ("roundy-label");
    }

    construct {
        halign = Gtk.Align.START;
        val = new Gtk.Label (Utils.NO_DATA) {
            selectable = true
        };
        val.add_css_class ("value");

        var header_label = new Granite.HeaderLabel (title.up ()) {
            mnemonic_widget = val
        };
        header_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        orientation = VERTICAL;
        append (header_label);
        append (val);
    }
}
