/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessTreeViewNameCell : Granite.Box {
    private Gtk.Image icon;
    private Gtk.Label label;

    public ProcessTreeViewNameCell () {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            child_spacing: Granite.Box.Spacing.HALF
        );
    }

    construct {
        icon = new Gtk.Image.from_icon_name ("application-x-executable") {
            pixel_size = 16
        };

        label = new Gtk.Label (Utils.NO_DATA);

        hexpand = true;
        halign = START;
        append (icon);
        append (label);
    }

    public void bind (ProcessRowData row_data) {
        label.label = row_data.name;
        icon.gicon = row_data.icon;
    }
}
