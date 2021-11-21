/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.PreferencesGeneralPage : Granite.SettingsPage {
    public Gtk.Switch background_switch;

    public PreferencesGeneralPage () {

        var icon = new Gtk.Image.from_icon_name ("preferences-system", Gtk.IconSize.DND);

        Object (
            display_widget: icon,
            //  status: "Spinning",
            //  header: "General Preferences",
            title: _("General")
        );
    }

    construct {
        var background_label = new Gtk.Label (_("Start in background:"));
        background_label.halign = Gtk.Align.START;

        background_switch = new Gtk.Switch ();
        background_switch.state = MonitorApp.settings.get_boolean ("background-state");
        background_switch.halign = Gtk.Align.END;
        background_switch.hexpand = true;
        //  set_background_switch_state ();

        var content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.margin = 12;
        content_area.attach (background_label, 0, 1, 1, 1);
        content_area.attach (background_switch, 1, 1, 1, 1);

        add (content_area);

        background_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("background-state", background_switch.state);
        });
    }


}
