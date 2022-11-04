/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.PreferencesGeneralPage : Granite.SettingsPage {
    public Gtk.Switch background_switch;
    public Gtk.Switch enable_smooth_lines_switch;

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


        var enable_smooth_lines_label = new Gtk.Label (_("Draw smooth lines on CPU chart (requires restart):"));
        enable_smooth_lines_label.halign = Gtk.Align.START;

        enable_smooth_lines_switch = new Gtk.Switch (); 
        enable_smooth_lines_switch.state = MonitorApp.settings.get_boolean ("smooth-lines-state");
        enable_smooth_lines_switch.halign = Gtk.Align.END;
        enable_smooth_lines_switch.hexpand = true;

        var refresh_time_label = new Gtk.Label (_("Update every:"));
        refresh_time_label.halign = Gtk.Align.START;
        var refresh_time_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 1, 5, 1);
        refresh_time_scale.halign = Gtk.Align.FILL;
        refresh_time_scale.hexpand = true;
        refresh_time_scale.set_draw_value (false);
        refresh_time_scale.add_mark (1.0, Gtk.PositionType.BOTTOM, "1s");
        refresh_time_scale.add_mark (2.0, Gtk.PositionType.BOTTOM, "2s");
        refresh_time_scale.add_mark (3.0, Gtk.PositionType.BOTTOM, "3s");
        refresh_time_scale.add_mark (4.0, Gtk.PositionType.BOTTOM, "4s");
        refresh_time_scale.add_mark (5.0, Gtk.PositionType.BOTTOM, "5s");



        var content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.margin = 12;
        content_area.attach (background_label, 0, 1, 1, 1);
        content_area.attach (background_switch, 1, 1, 1, 1);
        content_area.attach (enable_smooth_lines_label, 0, 2, 1, 1);
        content_area.attach (enable_smooth_lines_switch, 1, 2, 1, 1);
        content_area.attach (refresh_time_label, 0, 3, 1, 1);
        content_area.attach (refresh_time_scale, 0, 4, 1, 1);

        add (content_area);

        background_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("background-state", background_switch.state);
        });

        enable_smooth_lines_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("smooth-lines-state", enable_smooth_lines_switch.state);
        });
    }


}
