/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.PreferencesView : Granite.Bin {
    private Gtk.Adjustment update_freq_adjustment;

    construct {
        update_freq_adjustment = new Gtk.Adjustment (MonitorApp.settings.get_int ("update-time"), 1, 5, 1.0, 1, 0);
        var update_freq_scale = new Gtk.Scale (HORIZONTAL, update_freq_adjustment) {
            hexpand = true,
            draw_value = false,
            round_digits = 0,
        };

        var update_freq_label = new Gtk.Label (_("Update frequency")) {
            halign = START,
            mnemonic_widget = update_freq_scale
        };

        var update_freq_description = new Gtk.Label (_("Requires restart")) {
            halign = START,
            margin_bottom = 6
        };
        update_freq_description.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        update_freq_description.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        update_freq_scale.add_mark (1.0, BOTTOM, _("1s"));
        update_freq_scale.add_mark (2.0, BOTTOM, _("2s"));
        update_freq_scale.add_mark (3.0, BOTTOM, _("3s"));
        update_freq_scale.add_mark (4.0, BOTTOM, _("4s"));
        update_freq_scale.add_mark (5.0, BOTTOM, _("5s"));

        var update_freq_box = new Gtk.Box (VERTICAL, 0) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };
        update_freq_box.append (update_freq_label);
        update_freq_box.append (update_freq_description);
        update_freq_box.append (update_freq_scale);

        update_freq_adjustment.value_changed.connect (() => {
            MonitorApp.settings.set_int ("update-time", (int) update_freq_adjustment.get_value ());
        });

        var background_switch = new Granite.SwitchModelButton (_("Start in background"));

        var enable_smooth_lines_switch = new Granite.SwitchModelButton (_("Draw smooth lines on CPU chart")) {
            description = _("Requires restart")
        };

        var dbusserver = DBusServer.get_default ();

        var indicator_switch = new Granite.SwitchModelButton (_("Show in panel"));
        indicator_switch.notify["active"].connect (() => {
            dbusserver.indicator_state (indicator_switch.active);
        });

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
            margin_top = 6,
            margin_end = 12,
            margin_bottom = 6,
            margin_start = 12
        };
        indicator_options_box.append (cpu_check);
        indicator_options_box.append (cpu_freq_check);
        indicator_options_box.append (cpu_temp_check);
        indicator_options_box.append (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.append (memory_check);
        indicator_options_box.append (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.append (gpu_check);
        indicator_options_box.append (gpu_memory_check);
        indicator_options_box.append (gpu_temp_check);
        indicator_options_box.append (new Gtk.Separator (HORIZONTAL));
        indicator_options_box.append (network_upload_check);
        indicator_options_box.append (network_download_check);

        var indicator_options_revealer = new Gtk.Revealer () {
            child = indicator_options_box
        };

        var box = new Gtk.Box (VERTICAL, 0) {
            margin_bottom = 6
        };
        box.append (update_freq_box);
        box.append (enable_smooth_lines_switch);
        box.append (background_switch);
        box.append (indicator_switch);
        box.append (indicator_options_revealer);


        child = box;

        indicator_switch.bind_property ("active", indicator_options_revealer, "reveal-child", SYNC_CREATE);

        var settings = new GLib.Settings ("io.elementary.monitor.settings");
        settings.bind ("background-state", background_switch, "active", DEFAULT);
        // Allow changing the background preference only when the indicator is enabled
        settings.bind ("indicator-state", background_switch, "sensitive", GET);
        settings.bind ("smooth-lines-state", enable_smooth_lines_switch, "active", DEFAULT);

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
            "indicator-state", background_switch, "active", GET,
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
