/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.PreferencesView : Gtk.Box {
    private Gtk.Adjustment update_time_adjustment;

    construct {
        var background_label = new Gtk.Label (_("Start in background:")) {
            halign = START
        };

        var background_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true
        };

        var enable_smooth_lines_label = new Gtk.Label (_("Draw smooth lines on CPU chart (requires restart):")) {
            halign = START
        };

        var enable_smooth_lines_switch = new Gtk.Switch () {
            halign = END,
            hexpand = true
        };

        var update_time_label = new Gtk.Label (_("Update every (requires restart):")) {
            halign = START
        };

        update_time_adjustment = new Gtk.Adjustment (MonitorApp.settings.get_int ("update-time"), 1, 5, 1.0, 1, 0);
        var update_time_scale = new Gtk.Scale (HORIZONTAL, update_time_adjustment) {
            halign = FILL,
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
        content_area.attach (background_label, 0, 1);
        content_area.attach (background_switch, 1, 1);
        content_area.attach (enable_smooth_lines_label, 0, 2);
        content_area.attach (enable_smooth_lines_switch, 1, 2);
        content_area.attach (update_time_label, 0, 3);
        content_area.attach (update_time_scale, 0, 4, 2);

        update_time_adjustment.value_changed.connect (() => {
            MonitorApp.settings.set_int ("update-time", (int) update_time_adjustment.get_value ());
        });

        var dbusserver = DBusServer.get_default ();

        var indicator_switch = new Gtk.Switch () {
            halign = END
        };
        indicator_switch.notify["active"].connect (() => {
            dbusserver.indicator_state (indicator_switch.active);
        });

        var indicator_label = new Granite.HeaderLabel (_("Show in panel")) {
            hexpand = true,
            mnemonic_widget = indicator_switch
        };

        var indicator_header_box = new Gtk.Box (HORIZONTAL, 12) {
            margin_end = 12
        };
        indicator_header_box.add (indicator_label);
        indicator_header_box.add (indicator_switch);

        var cpu_check = new Gtk.CheckButton.with_label (_("CPU percentage"));
        cpu_check.toggled.connect (() => {
            dbusserver.indicator_cpu_state (cpu_check.active);
        });

        var cpu_freq_check = new Gtk.CheckButton.with_label (_("CPU frequency"));
        cpu_freq_check.toggled.connect (() => {
            dbusserver.indicator_cpu_frequency_state (cpu_freq_check.active);
        });

        var cpu_temp_check = new Gtk.CheckButton.with_label (_("CPU temperature"));
        cpu_temp_check.toggled.connect (() => {
            dbusserver.indicator_cpu_temperature_state (cpu_temp_check.active);
        });

        var memory_check = new Gtk.CheckButton.with_label (_("RAM percentage"));
        memory_check.toggled.connect (() => {
            dbusserver.indicator_memory_state (memory_check.active);
        });

        var network_upload_check = new Gtk.CheckButton.with_label (_("Network upload"));
        network_upload_check.toggled.connect (() => {
            dbusserver.indicator_network_up_state (network_upload_check.active);
        });

        var network_download_check = new Gtk.CheckButton.with_label (_("Network download"));
        network_download_check.toggled.connect (() => {
            dbusserver.indicator_network_down_state (network_download_check.active);
        });

        var gpu_check = new Gtk.CheckButton.with_label (_("GPU percentage"));
        gpu_check.toggled.connect (() => {
            dbusserver.indicator_gpu_state (gpu_check.active);
        });

        var gpu_memory_check = new Gtk.CheckButton.with_label (_("VRAM percentage"));
        gpu_memory_check.toggled.connect (() => {
            dbusserver.indicator_gpu_memory_state (gpu_memory_check.active);
        });

        var gpu_temp_check = new Gtk.CheckButton.with_label (_("GPU temperature"));
        gpu_temp_check.toggled.connect (() => {
            dbusserver.indicator_gpu_temperature_state (gpu_temp_check.active);
        });

        var row = 0;

        var indicator_options_box = new Gtk.Box (VERTICAL, 6) {
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12
        };
        indicator_options_box.add (cpu_check);
        indicator_options_box.add (cpu_freq_check);
        indicator_options_box.add (cpu_temp_check);
        indicator_options_box.add (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.add (memory_check);
        indicator_options_box.add (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.add (gpu_check);
        indicator_options_box.add (gpu_memory_check);
        indicator_options_box.add (gpu_temp_check);
        indicator_options_box.add (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.add (network_upload_check);
        indicator_options_box.add (network_download_check);

        var indicator_options_revealer = new Gtk.Revealer () {
            child = indicator_options_box
        };

        add (content_area);
        add (indicator_header_box);
        add (indicator_options_revealer);

        width_request = 500;
        orientation = VERTICAL;
        spacing = 12;

        indicator_switch.bind_property ("active", indicator_options_revealer, "reveal-child", SYNC_CREATE);

        var settings = new GLib.Settings ("io.elementary.monitor.settings");
        settings.bind ("background-state", background_switch, "state", DEFAULT);
        // Allow changing the background preference only when the indicator is enabled
        settings.bind ("indicator-state", background_switch, "sensitive", GET);
        settings.bind ("smooth-lines-state", enable_smooth_lines_switch, "state", DEFAULT);

        settings.bind ("indicator-state", indicator_switch, "active", DEFAULT);
        settings.bind ("indicator-cpu-state", cpu_check, "active", DEFAULT);
        settings.bind ("indicator-cpu-frequency-state", cpu_freq_check, "active", DEFAULT);
        settings.bind ("indicator-cpu-temperature-state", cpu_temp_check, "active", DEFAULT);
        settings.bind ("indicator-memory-state", memory_check, "active", DEFAULT);
        settings.bind ("indicator-gpu-temperature-state", gpu_temp_check, "active", DEFAULT);
        settings.bind ("indicator-gpu-memory-state", gpu_memory_check, "active", DEFAULT);
        settings.bind ("indicator-gpu-state", gpu_check, "active", DEFAULT);
        settings.bind ("indicator-network-download-state", network_download_check, "active", DEFAULT);
        settings.bind ("indicator-network-upload-state", network_upload_check, "active", DEFAULT);

        // Disable the background preference when the indicator is enabled
        settings.bind_with_mapping (
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
    }
}
