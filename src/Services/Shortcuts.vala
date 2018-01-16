namespace Monitor {
    public class Shortcuts {

        public signal void search_signal ();
        public signal void expand_row_signal ();
        public signal void collapse_row_signal ();
        public signal void end_process_signal ();
        
        // taken from Torrential
        private SimpleActionGroup actions = new SimpleActionGroup ();
        private const string ACTION_GROUP_PREFIX_NAME = "monitor";
        private const string ACTION_GROUP_PREFIX = ACTION_GROUP_PREFIX_NAME + ".";
        private const string ACTION_SEARCH = "search";
        private const string ACTION_EXPAND_ROW = "expand_row";
        private const string ACTION_COLLAPSE_ROW = "collapse_row";
        private const string ACTION_END_PROCESS = "end_process";

        private const ActionEntry[] action_entries = {
            { ACTION_SEARCH,                search          },
            { ACTION_EXPAND_ROW,            expand_row          },
            { ACTION_COLLAPSE_ROW,          collapse_row          },
            { ACTION_END_PROCESS,          end_process          },

        };

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        static construct {
            action_accelerators.set (ACTION_SEARCH, "<Ctrl>F");
            action_accelerators.set (ACTION_EXPAND_ROW, "Right");
            action_accelerators.set (ACTION_COLLAPSE_ROW, "Left");
            action_accelerators.set (ACTION_END_PROCESS, "<Ctrl>E");
        }

        public Shortcuts(Gtk.Window window, MonitorApp app) {
            actions.add_action_entries (action_entries, this);
            window.insert_action_group (ACTION_GROUP_PREFIX_NAME, actions);
            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_GROUP_PREFIX + action, action_accelerators[action].to_array ());
            }
        }

        private void search () {
            search_signal ();
        }

        private void expand_row () {
            expand_row_signal ();
        }

        private void collapse_row () {
            collapse_row_signal ();
        }

        private void end_process () {
            end_process_signal ();
        }
    }

}