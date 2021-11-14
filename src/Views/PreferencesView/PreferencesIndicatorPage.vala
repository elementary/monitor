/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.SimpleSettingsPage : Granite.SimpleSettingsPage {
    public SimpleSettingsPage () {
        Object (
            activatable: true,
            description: _("Indicator Preferences"),
            //  header: "Simple Pages",
            icon_name: "preferences-system",
            title: _("Indicator")
        );
    }

    construct {
        var cpu_label = new Gtk.Label (_("Display CPU percentage"));
        cpu_label.halign = Gtk.Align.START;
        cpu_label.xalign = 1;

        var cpu_percentage_switch = new Gtk.Switch ();
        cpu_percentage_switch.halign = Gtk.Align.END;
        cpu_percentage_switch.hexpand = true;
        cpu_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-state");

        var memory_label = new Gtk.Label (_("Display Memory percentage"));
        memory_label.halign = Gtk.Align.START;
        memory_label.xalign = 1;

        var memory_percentage_switch = new Gtk.Switch ();
        memory_percentage_switch.halign = Gtk.Align.END;
        memory_percentage_switch.state = MonitorApp.settings.get_boolean ("indicator-state");

        var temperature_label = new Gtk.Label (_("Display temperature"));
        temperature_label.halign = Gtk.Align.START;
        temperature_label.xalign = 1;

        var temperature_switch = new Gtk.Switch ();
        temperature_switch.halign = Gtk.Align.END;
        temperature_switch.state = MonitorApp.settings.get_boolean ("indicator-state");

        content_area.attach (cpu_label, 0, 0, 1, 1);
        content_area.attach (cpu_percentage_switch, 1, 0, 1, 1);
        content_area.attach (memory_label, 0, 1, 1, 1);
        content_area.attach (memory_percentage_switch, 1, 1, 1, 1);
        content_area.attach (temperature_label, 0, 2, 1, 1);
        content_area.attach (temperature_switch, 1, 2, 1, 1);

        update_status ();


        status_switch.notify["active"].connect (update_status);

        cpu_percentage_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-state", cpu_percentage_switch.state);
            //  window.dbusserver.indicator_state (show_indicator_switch.state);
        });

    }

    private void update_status () {
        if (status_switch.active) {
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = _("Enabled");
        } else {
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = _("Disabled");
        }
    }
}