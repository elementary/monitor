/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

 public class Monitor.PreferencesView : Gtk.Paned {
    construct {
        var indicator_page = new SimpleSettingsPage ();
        var general_page = new PreferencesGeneralPage ();
        height_request = 300;
        width_request = 500;

        var stack = new Gtk.Stack ();
        //  stack.add_named (general_page, "general_page");
        stack.add_named (indicator_page, "indicator_page");

        var settings_sidebar = new Granite.SettingsSidebar (stack);

        add (settings_sidebar);
        add (stack);
    }
}