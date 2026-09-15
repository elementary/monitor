/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.LogCell : Granite.Bin {
    public enum CellType {
        ORIGIN,
        MESSAGE,
        PRIORITY
    }

    public CellType cell_type { get; construct; }

    private Gtk.Label label;

    public LogCell (CellType cell_type) {
        Object (cell_type: cell_type);
    }

    construct {
        label = new Gtk.Label (null);

        switch (cell_type) {
            case ORIGIN:
                label.add_css_class (Granite.CssClass.DIM);
                label.width_chars = 15;
                label.xalign = 1;
                break;
            case MESSAGE:
                label.halign = START;
                break;
        }

        child = label;
    }

    public void bind (SystemdLogEntry entry) {
        switch (cell_type) {
            case ORIGIN:
                label.label = entry.origin;
                break;
            case MESSAGE:
                label.label = entry.message;
                break;
        }
    }
}
