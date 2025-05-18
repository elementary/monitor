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
        val.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        desc = new Gtk.Label (description.up ());
        desc.add_css_class ("small-text");

        grid.attach (desc, 0, 0, 1, 1);
        grid.attach (val, 0, 1, 1, 1);

        append (grid);

        // @TODO: Find out why it was here.
        // It is probably a remainings of expandable label,
        // which is not a thing anymore.

        // events |= Gdk.EventMask.BUTTON_RELEASE_MASK;

        // button_release_event.connect ((event) => {
        // clicked ();
        // return false;
        // });
    }

    public void set_text (string text) {
        val.set_text (text);
    }

}
