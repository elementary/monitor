namespace Monitor {

    public class Search :  Gtk.SearchEntry {
        public Gtk.TreeModelFilter filter_model { get; private set; }
        private OverallView process_view;

        public Search (OverallView process_view, Gtk.TreeModel model) {
            this.process_view = process_view;
            this.placeholder_text = _("Search Process");
            this.set_tooltip_text (_("Type Process Name or PID"));
            filter_model = new Gtk.TreeModelFilter (model, null);
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
            this.grab_focus ();
            this.insert_at_cursor (search_text);
        }

    }
}
