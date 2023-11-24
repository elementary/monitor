public class Monitor.Search : Gtk.Box {
    private Gtk.TreeModelFilter filter_model;
    private CPUProcessTreeView process_tree_view;
    private Gtk.SearchEntry search_entry;

    construct {
        search_entry = new Gtk.SearchEntry () {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>F" }, _("Type process name or PID to search")),
        };
        search_entry.placeholder_text = _("Search Process");

        filter_model = new Gtk.TreeModelFilter (Monitor.TreeViewModel.get_default (), null);
        connect_signal ();
        filter_model.set_visible_func (filter_func);
        // process_tree_view.set_model (filter_model);

        var sort_model = new Gtk.TreeModelSort.with_model (filter_model);
        //  process_tree_view.set_model (sort_model);
        append (search_entry);
    }

    private void connect_signal () {
        search_entry.search_changed.connect (() => {
            // collapse tree only when search is focused and changed
            //  if (this.is_focus) {
            //      process_tree_view.collapse_all ();
            //  }

            filter_model.refilter ();

            // focus on child row to avoid the app crashes by clicking "Kill/End Process" buttons in headerbar
            process_tree_view.focus_on_child_row ();
            search_entry.grab_focus ();

            //  if (this.text != "") {
            //      this.insert_at_cursor ("");
            //  }
        });
    }

    private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
        string name_haystack;
        int pid_haystack;
        string cmd_haystack;
        bool found = false;
        var needle = search_entry.text;

        // should help with assertion errors, donno
        // if (needle == null) return true;

        if (needle.length == 0) {
            return true;
        }

        model.get (iter, Column.NAME, out name_haystack, -1);
        model.get (iter, Column.PID, out pid_haystack, -1);
        model.get (iter, Column.CMD, out cmd_haystack, -1);

        // sometimes name_haystack is null
        if (name_haystack != null) {
            bool name_found = name_haystack.casefold ().contains (needle.casefold ()) || false;
            bool pid_found = pid_haystack.to_string ().casefold ().contains (needle.casefold ()) || false;
            bool cmd_found = cmd_haystack.casefold ().contains (needle.casefold ()) || false;
            found = name_found || pid_found || cmd_found;
        }


        Gtk.TreeIter child_iter;
        bool child_found = false;

        if (model.iter_children (out child_iter, iter)) {
            do {
                child_found = filter_func (model, child_iter);
            } while (model.iter_next (ref child_iter) && !child_found);
        }

        if (child_found && needle.length > 0) {
            process_tree_view.expand_all ();
        }

        return found || child_found;
    }

    // reset filter, grab focus and insert the character
    public void activate_entry (string search_text = "") {
        search_entry.text = "";
        search_entry.search_changed ();
        //  this.insert_at_cursor (search_text);
    }

}
