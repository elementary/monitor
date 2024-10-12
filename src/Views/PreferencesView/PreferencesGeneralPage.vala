/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * Copyright 2022 @stsdc
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Monitor.PreferencesGeneralPage : Granite.SettingsPage {
    private Gtk.Adjustment update_time_adjustment;

    public PreferencesGeneralPage () {
        Object (
            display_widget: new Gtk.Image.from_icon_name ("preferences-system", Gtk.IconSize.DND),
            title: _("General")
        );
    }

    construct {
        var background_label = new Gtk.Label (_("Start in background:")) {
            halign = Gtk.Align.START
        };

        var background_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            hexpand = true
        };

        var enable_smooth_lines_label = new Gtk.Label (_("Draw smooth lines on CPU chart (requires restart):")) {
            halign = Gtk.Align.START
        };

        var enable_smooth_lines_switch = new Gtk.Switch () {
            halign = Gtk.Align.END,
            hexpand = true
        };

        var update_time_label = new Gtk.Label (_("Update every (requires restart):")) {
            halign = Gtk.Align.START
        };

        update_time_adjustment = new Gtk.Adjustment (MonitorApp.settings.get_int ("update-time"), 1, 5, 1.0, 1, 0);
        var update_time_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, update_time_adjustment) {
            halign = Gtk.Align.FILL,
            hexpand = true,
            draw_value = false,
            round_digits = 0,
        };

        update_time_scale.add_mark (1.0, Gtk.PositionType.BOTTOM, _("1s"));
        update_time_scale.add_mark (2.0, Gtk.PositionType.BOTTOM, _("2s"));
        update_time_scale.add_mark (3.0, Gtk.PositionType.BOTTOM, _("3s"));
        update_time_scale.add_mark (4.0, Gtk.PositionType.BOTTOM, _("4s"));
        update_time_scale.add_mark (5.0, Gtk.PositionType.BOTTOM, _("5s"));

        var content_area = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 12,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };
        content_area.attach (background_label, 0, 1, 1, 1);
        content_area.attach (background_switch, 1, 1, 1, 1);
        content_area.attach (enable_smooth_lines_label, 0, 2, 1, 1);
        content_area.attach (enable_smooth_lines_switch, 1, 2, 1, 1);
        content_area.attach (update_time_label, 0, 3, 1, 1);
        content_area.attach (update_time_scale, 0, 4, 1, 1);

        add (content_area);

        MonitorApp.settings.bind ("background-state", background_switch, "state", DEFAULT);

        // Allow changing the background preference only when the indicator is enabled
        MonitorApp.settings.bind ("indicator-state", background_switch, "sensitive", GET);

        // Disable the background preference when the indicator is enabled
        MonitorApp.settings.bind_with_mapping (
            "indicator-state", background_switch, "state", GET,
            (switch_state, settings_state, user_data) => {
                bool state = settings_state.get_boolean ();
                if (!state) {
                    switch_state.set_boolean (false);
                }

                return true;
            },
            (SettingsBindSetMappingShared) null, null, null
        );

        MonitorApp.settings.bind ("smooth-lines-state", enable_smooth_lines_switch, "state", DEFAULT);

        update_time_adjustment.value_changed.connect (() => {
            MonitorApp.settings.set_int ("update-time", (int) update_time_adjustment.get_value ());
        });
    }
}
