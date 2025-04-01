/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class LabelH4 : Gtk.Label {
    construct {
        get_style_context ().add_class ("h4");
        valign = Gtk.Align.START;
        halign = Gtk.Align.START;
        margin_start = 6;
        ellipsize = Pango.EllipsizeMode.END;
    }

    public LabelH4 (string label) {
        Object (label: label);
    }

}
