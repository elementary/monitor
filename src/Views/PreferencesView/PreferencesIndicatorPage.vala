/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.SimpleSettingsPage : Granite.SimpleSettingsPage {
    private DBusServer dbusserver;

    public SimpleSettingsPage () {
        Object (
            activatable: true,
            description: _("Show Indicator in Wingpanel"),
            //  header: "Simple Pages",
            icon_name: "preferences-system",
            title: _("Indicator")
        );
    }

    construct {
        dbusserver = DBusServer.get_default ();

        var cpu_label = new Gtk.Label (_("Display CPU percentage"));
        cpu_label.halign = Gtk.Align.START;
        cpu_label.xalign = 1;

        var cpu_percentage_switch = new Gtk.Switch ();
        cpu_percentage_switch.halign = Gtk.Align.END;
        cpu_percentage_switch.hexpand = true;
        cpu_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-cpu-state");
        cpu_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", cpu_percentage_switch.state);
            dbusserver.indicator_cpu_state (cpu_percentage_switch.state);
        });

        var memory_label = new Gtk.Label (_("Display Memory percentage"));
        memory_label.halign = Gtk.Align.START;
        memory_label.xalign = 1;

        var memory_percentage_switch = new Gtk.Switch ();
        memory_percentage_switch.halign = Gtk.Align.END;
        memory_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-memory-state");
        memory_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-memory-state", memory_percentage_switch.state);
            dbusserver.indicator_memory_state (memory_percentage_switch.state);
        });

        var temperature_label = new Gtk.Label (_("Display temperature"));
        temperature_label.halign = Gtk.Align.START;
        temperature_label.xalign = 1;

        var temperature_switch = new Gtk.Switch ();
        temperature_switch.halign = Gtk.Align.END;
        temperature_switch.state = MonitorApp.settings.get_boolean ("indicator-temperature-state");
        temperature_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-temperature-state", temperature_switch.state);
            dbusserver.indicator_temperature_state (temperature_switch.state);
        });

        content_area.attach (cpu_label, 0, 0, 1, 1);
        content_area.attach (cpu_percentage_switch, 1, 0, 1, 1);
        content_area.attach (memory_label, 0, 1, 1, 1);
        content_area.attach (memory_percentage_switch, 1, 1, 1, 1);
        content_area.attach (temperature_label, 0, 2, 1, 1);
        content_area.attach (temperature_switch, 1, 2, 1, 1);

        update_status ();

        status_switch.notify["active"].connect (update_status);
    }

    private void update_status () {
        if (status_switch.active) {
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = _("Enabled");
        } else {
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = _("Disabled");
        }
        MonitorApp.settings.set_boolean ("indicator-state", status_switch.state);
        dbusserver.indicator_state (status_switch.state);
    }
}