namespace elementarySystemMonitor {
    public class Shortcuts {
//          static Shortcuts? shortcuts = null;

        public signal void search_signal ();
        
        // taken from Torrential
        private SimpleActionGroup actions = new SimpleActionGroup ();
        private const string ACTION_GROUP_PREFIX_NAME = "monitor";
        private const string ACTION_GROUP_PREFIX = ACTION_GROUP_PREFIX_NAME + ".";
        private const string ACTION_SEARCH = "search";

        private const ActionEntry[] action_entries = {
            { ACTION_SEARCH,                search          }
        };

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        static construct {
            action_accelerators.set (ACTION_SEARCH, "<Ctrl>f");
        }

        public Shortcuts(Gtk.Window window, elementarySystemMonitorApp app) {
            actions.add_action_entries (action_entries, this);
            window.insert_action_group (ACTION_GROUP_PREFIX_NAME, actions);
            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_GROUP_PREFIX + action, action_accelerators[action].to_array ());
            }
        }

        private void search () {
            search_signal ();
        }
    }

}