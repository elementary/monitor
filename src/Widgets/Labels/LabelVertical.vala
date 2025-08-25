/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.LabelVertical : Gtk.Box {
    private Gtk.Grid grid;

    public signal void clicked ();

    public Gtk.Label val;
    public Gtk.Label desc;

    construct {
        grid = new Gtk.Grid ();
        margin_start = 12;
        margin_top = 6;

        add_css_class ("label-vertical");
    }

    public LabelVertical (string description) {
        val = new Gtk.Label (Utils.NO_DATA);

        // Semantically Granite.STYLE_CLASS_H2_LABEL would be correct
        // however the H2 is not taking enough height
        // Needs design
        val.add_css_class ("label-vertical-val");

        // this can be archived by Gtk.STYLE_CLASS_DIM_LABEL and
        // Granite.STYLE_CLASS_SMALL_LABEL, however the style
        // differs from the OG
        desc = new Gtk.Label (description.up ());
        desc.add_css_class ("small-label");

        grid.attach (desc, 0, 0, 1, 1);
        grid.attach (val, 0, 1, 1, 1);

        append (grid);
    }

    public void set_text (string text) {
        val.set_text (text);
    }

}
