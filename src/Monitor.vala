/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

namespace Monitor {
    public class MonitorApp : Gtk.Application {
        public static Settings settings;
        private MainWindow window = null;
        public string[] args;

        private static bool start_in_background = false;
        private static bool status_background = false;
        private const GLib.OptionEntry[] CMD_OPTIONS = {
            // --start-in-background
            { "start-in-background", 'b', 0, OptionArg.NONE, ref start_in_background, "Start in background with wingpanel indicator", null },
            // list terminator
            { null }
        };

        // constructor replacement, flags added
        public MonitorApp (bool status_indicator) {
            Object (
                application_id: "io.elementary.monitor",
                flags : ApplicationFlags.FLAGS_NONE
                );
            status_background = status_indicator;
        }

        static construct {
            settings = new Settings ("io.elementary.monitor.settings");
        }

        public override void startup () {
            base.startup ();

            Hdy.init ();

            Appearance.set_prefered_style ();

            // Controls the direction of the sort indicators
            Gtk.Settings.get_default ().set ("gtk-alternative-sort-arrows", true, null);

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });

            set_accels_for_action ("app.quit", { "<Ctrl>q" });
            set_accels_for_action ("win.search", { "<Ctrl>f" });
            set_accels_for_action ("process.end", { "<Ctrl>e" });
            set_accels_for_action ("process.kill", { "<Ctrl>k" });
        }

        public override void activate () {
            // only have one window
            if (get_windows () != null) {
                window.show_all ();
                window.present ();
                return;
            }

            window = new MainWindow (this);

            // start in background with indicator
            if (status_background || MonitorApp.settings.get_boolean ("background-state")) {
                if (!MonitorApp.settings.get_boolean ("indicator-state")) {
                    MonitorApp.settings.set_boolean ("indicator-state", true);
                }
                // if (!MonitorApp.settings.get_boolean ("indicator-cpu-state")) {
                // MonitorApp.settings.set_boolean ("indicator-cpu-state", true);
                // }
                // if (!MonitorApp.settings.get_boolean ("indicator-memory-state")) {
                // MonitorApp.settings.set_boolean ("indicator-memory-state", true);
                // }
                // if (!MonitorApp.settings.get_boolean ("indicator-temperature-state")) {
                // MonitorApp.settings.set_boolean ("indicator-temperature-state", true);
                // }
                // if (!MonitorApp.settings.get_boolean ("indicator-network-upload-state")) {
                // MonitorApp.settings.set_boolean ("indicator-network-upload-state", false);
                // }
                // if (!MonitorApp.settings.get_boolean ("indicator-network-download-state")) {
                // MonitorApp.settings.set_boolean ("indicator-network-download-state", false);
                // }

                window.hide ();
                MonitorApp.settings.set_boolean ("background-state", true);
            } else {
                window.show_all ();
            }

            window.process_view.process_tree_view.focus_on_first_row ();
        }

        public static int main (string[] args) {
            Intl.setlocale ();
            print ("\n");
            print (" Monitor %s \n", VCS_TAG);
            print ("\n");

            print (
                "LibPCI ver: %d.%d.%d \n",
                PCIUtils.LIBPCI_MAJOR_VER,
                PCIUtils.LIBPCI_MINOR_VER,
                PCIUtils.LIBPCI_PATCH_VER
                );

            // add command line options
            try {
                var opt_context = new OptionContext ("");
                opt_context.set_help_enabled (true);
                opt_context.add_main_entries (CMD_OPTIONS, null);
                opt_context.parse (ref args);
            } catch (OptionError e) {
                print ("Error: %s\n", e.message);
                print ("Run '%s --help' to see a full list of available command line options.\n\n", args[0]);
                return 0;
            }

            var app = new MonitorApp (start_in_background);

            return app.run (args);
        }

    }
}
