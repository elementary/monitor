namespace Monitor {

    public class Search :  Gtk.SearchEntry {
        public MainWindow window { get; construct; }
        private Gtk.TreeModelFilter filter_model;
        private OverallView process_view;

        public Search (MainWindow window) {
            Object (window: window);
        }

        construct {
            this.process_view = window.process_view;
            this.placeholder_text = _("Search Process");
            this.tooltip_text = _("Type Process Name or PID");

            filter_model = new Gtk.TreeModelFilter (window.generic_model, null);
            connect_signal ();
            filter_model.set_visible_func(filter_func);
            process_view.set_model (filter_model);

            var sort_model = new Gtk.TreeModelSort.with_model (filter_model);
            process_view.set_model (sort_model);
        }

        private void connect_signal () {
            this.search_changed.connect (() => {
                // collapse tree only when search is focused and changed
                if (this.is_focus) {
                    process_view.collapse_all ();
                }

                filter_model.refilter ();

                // if there's no search result, make "Kill/End Process" buttons in headerbar insensitive to avoid the app crashes
                window.headerbar.set_header_buttons_sensitivity (filter_model.iter_n_children (null) != 0);

                // focus on child row to avoid the app crashes by clicking "Kill/End Process" buttons in headerbar
                process_view.focus_on_child_row ();
                this.grab_focus ();

                if (this.text != "") {
                    this.insert_at_cursor ("");
                }
            });
        }

        private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
            string name_haystack;
            int pid_haystack;
            bool found = false;
            var needle = this.text;
            if ( needle.length == 0 ) {
                return true;
            }

            model.get( iter, Column.NAME, out name_haystack, -1 );
            model.get( iter, Column.PID, out pid_haystack, -1 );

            // sometimes name_haystack is null
            if (name_haystack != null) {
                bool name_found = name_haystack.casefold().contains(needle.casefold()) || false;
                bool pid_found = pid_haystack.to_string().casefold().contains(needle.casefold()) || false;
                found = name_found || pid_found;
            }


            Gtk.TreeIter child_iter;
            bool child_found = false;

            if (model.iter_children (out child_iter, iter)) {
                do {
                    child_found = filter_func (model, child_iter);
                } while (model.iter_next (ref child_iter) && !child_found);
            }

            if (child_found && needle.length > 0) {
                process_view.expand_all ();
            }

            return found || child_found;
        }

        // reset filter, grab focus and insert the character
        public void activate_entry (string search_text = "") {
            this.text = "";
            this.search_changed ();
            this.insert_at_cursor (search_text);
        }

    }
}
