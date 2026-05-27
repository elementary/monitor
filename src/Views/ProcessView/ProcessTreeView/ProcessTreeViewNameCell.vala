/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessTreeViewNameCell : Gtk.Box {
    public Gtk.Image icon;
    public Gtk.Label label;

    public ProcessTreeViewNameCell () {
        hexpand = true;
        halign = START;

        icon = new Gtk.Image.from_icon_name ("application-x-executable") {
            pixel_size = 16
        };
        label = new Gtk.Label (Utils.NO_DATA);

        append (icon);
        append (label);
    }

}
