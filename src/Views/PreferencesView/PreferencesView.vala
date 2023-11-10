/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.PreferencesView : Gtk.Box {
    private PreferencesGeneralPage general_page = new PreferencesGeneralPage ();
    private PreferencesIndicatorPage indicator_page = new PreferencesIndicatorPage ();

    construct {
        set_background_switch_state ();
        general_page.background_switch.notify["active"].connect (() => set_background_switch_state ());
        indicator_page.status_switch.notify["active"].connect (() => set_background_switch_state ());

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        height_request = 300;
        width_request = 500;
        paned.set_position (135);

        var stack = new Gtk.Stack ();
        stack.add_named (indicator_page, "indicator_page");
        stack.add_named (general_page, "general_page");

        var settings_sidebar = new Granite.SettingsSidebar (stack) {
            width_request = 135
        };

        paned.set_start_child (settings_sidebar);
        paned.set_end_child (stack);
        append (paned);
    }

    private void set_background_switch_state () {
        general_page.background_switch.sensitive = indicator_page.status_switch.active;

        if (!indicator_page.status_switch.active) {
            general_page.background_switch.state = false;
        }
    }
}
