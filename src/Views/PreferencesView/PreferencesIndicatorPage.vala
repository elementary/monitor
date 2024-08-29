/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.PreferencesIndicatorPage : Granite.SimpleSettingsPage {
    private DBusServer dbusserver;

    public PreferencesIndicatorPage () {
        Object (
            activatable: true,
            description: _("Show indicator in Wingpanel"),
            //  header: "Simple Pages",
            icon_name: "preferences-system",
            title: _("Indicator")
        );
    }

    construct {
        dbusserver = DBusServer.get_default ();
        status_switch.set_active (MonitorApp.settings.get_boolean ("indicator-state"));

        var cpu_label = new Gtk.Label (_("Display CPU percentage"));
        cpu_label.halign = Gtk.Align.START;
        cpu_label.xalign = 1;

        // TODO: needs switch and label builder
        var cpu_percentage_switch = new Gtk.Switch ();
        cpu_percentage_switch.halign = Gtk.Align.END;
        cpu_percentage_switch.hexpand = true;
        cpu_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-cpu-state");
        cpu_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", cpu_percentage_switch.state);
            dbusserver.indicator_cpu_state (cpu_percentage_switch.state);
        });

        var cpu_frequency_label = new Gtk.Label (_("Display CPU frequency"));
        cpu_frequency_label.halign = Gtk.Align.START;
        cpu_frequency_label.xalign = 1;

        var cpu_frequency_switch = new Gtk.Switch ();
        cpu_frequency_switch.halign = Gtk.Align.END;
        cpu_frequency_switch.hexpand = true;
        cpu_frequency_switch.state = MonitorApp.settings.get_boolean ("indicator-cpu-frequency-state");
        cpu_frequency_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-frequency-state", cpu_frequency_switch.state);
            dbusserver.indicator_cpu_frequency_state (cpu_frequency_switch.state);
        });

        var cpu_temperature_label = new Gtk.Label (_("Display CPU temperature"));
        cpu_temperature_label.halign = Gtk.Align.START;
        cpu_temperature_label.xalign = 1;

        var cpu_temperature_switch = new Gtk.Switch ();
        cpu_temperature_switch.halign = Gtk.Align.END;
        cpu_temperature_switch.state = MonitorApp.settings.get_boolean ("indicator-cpu-temperature-state");
        cpu_temperature_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-temperature-state", cpu_temperature_switch.state);
            dbusserver.indicator_cpu_temperature_state (cpu_temperature_switch.state);
        });

        var memory_label = new Gtk.Label (_("Display RAM percentage"));
        memory_label.halign = Gtk.Align.START;
        memory_label.xalign = 1;

        var memory_percentage_switch = new Gtk.Switch ();
        memory_percentage_switch.halign = Gtk.Align.END;
        memory_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-memory-state");
        memory_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-memory-state", memory_percentage_switch.state);
            dbusserver.indicator_memory_state (memory_percentage_switch.state);
        });    

        var network_upload_label = new Gtk.Label (_("Display network upload"));
        network_upload_label.halign = Gtk.Align.START;
        network_upload_label.xalign = 1;

        var network_upload_switch = new Gtk.Switch ();
        network_upload_switch.halign = Gtk.Align.END;
        network_upload_switch.state = MonitorApp.settings.get_boolean ("indicator-network-upload-state");
        network_upload_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-network-upload-state", network_upload_switch.state);
            dbusserver.indicator_network_up_state (network_upload_switch.state);
        });

        var network_download_label = new Gtk.Label (_("Display network download"));
        network_download_label.halign = Gtk.Align.START;
        network_download_label.xalign = 1;

        var network_download_switch = new Gtk.Switch ();
        network_download_switch.halign = Gtk.Align.END;
        network_download_switch.state = MonitorApp.settings.get_boolean ("indicator-network-download-state");
        network_download_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-network-download-state", network_download_switch.state);
            dbusserver.indicator_network_down_state (network_download_switch.state);
        });

        var gpu_label = new Gtk.Label (_("Display GPU percentage"));
        gpu_label.halign = Gtk.Align.START;
        gpu_label.xalign = 1;

        var gpu_percentage_switch = new Gtk.Switch ();
        gpu_percentage_switch.halign = Gtk.Align.END;
        gpu_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-gpu-state");
        gpu_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-gpu-state", gpu_percentage_switch.state);
            dbusserver.indicator_gpu_state (gpu_percentage_switch.state);
        });

        var gpu_memory_label = new Gtk.Label (_("Display VRAM percentage"));
        gpu_memory_label.halign = Gtk.Align.START;
        gpu_memory_label.xalign = 1;

        var gpu_memory_switch = new Gtk.Switch ();
        gpu_memory_switch.halign = Gtk.Align.END;
        gpu_memory_switch.state = MonitorApp.settings.get_boolean ("indicator-gpu-memory-state");
        gpu_memory_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-gpu-temperature-state", gpu_memory_switch.state);
            dbusserver.indicator_gpu_memory_state (gpu_memory_switch.state);
        });

        var gpu_temperature_label = new Gtk.Label (_("Display GPU temperature"));
        gpu_temperature_label.halign = Gtk.Align.START;
        gpu_temperature_label.xalign = 1;

        var gpu_temperature_switch = new Gtk.Switch ();
        gpu_temperature_switch.halign = Gtk.Align.END;
        gpu_temperature_switch.state = MonitorApp.settings.get_boolean ("indicator-gpu-temperature-state");
        gpu_temperature_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-gpu-temperature-state", gpu_temperature_switch.state);
            dbusserver.indicator_gpu_temperature_state (gpu_temperature_switch.state);
        });

        var row = 0;

        content_area.attach (cpu_label, 0, row, 1, 1);
        content_area.attach (cpu_percentage_switch, 1, row, 1, 1);
        row++;

        content_area.attach (cpu_frequency_label, 0, row, 1, 1);
        content_area.attach (cpu_frequency_switch, 1, row, 1, 1);
        row++;

        content_area.attach (cpu_temperature_label, 0, row, 1, 1);
        content_area.attach (cpu_temperature_switch, 1, row, 1, 1);
        row++;

        content_area.attach(new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, row, 2, 1);
        row++;

        content_area.attach (memory_label, 0, row, 1, 1);
        content_area.attach (memory_percentage_switch, 1, row, 1, 1);
        row++;

        content_area.attach(new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, row, 2, 1);
        row++;

        content_area.attach (gpu_label, 0, row, 1, 1);
        content_area.attach (gpu_percentage_switch, 1, row, 1, 1);
        row++;

        content_area.attach (gpu_memory_label, 0, row, 1, 1);
        content_area.attach (gpu_memory_switch, 1, row, 1, 1);
        row++;

        content_area.attach (gpu_temperature_label, 0, row, 1, 1);
        content_area.attach (gpu_temperature_switch, 1, row, 1, 1);
        row++;

        content_area.attach(new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, row, 2, 1);
        row++;

        content_area.attach (network_upload_label, 0, row, 1, 1);
        content_area.attach (network_upload_switch, 1, row, 1, 1);
        row++;

        content_area.attach (network_download_label, 0, row, 1, 1);
        content_area.attach (network_download_switch, 1, row, 1, 1);

        update_status ();

        status_switch.notify["active"].connect (update_status);
    }

    private void update_status () {
        if (status_switch.active) {
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = _("Enabled");
            MonitorApp.settings.set_boolean ("indicator-state", status_switch.active);
            dbusserver.indicator_state (status_switch.state);
        } else {
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = _("Disabled");
            MonitorApp.settings.set_boolean ("indicator-state", status_switch.active);
            dbusserver.indicator_state (status_switch.state);
        }

    }
}
