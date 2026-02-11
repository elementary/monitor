
public class Monitor.ProcessTreeView : Granite.Bin {
    private Gtk.ColumnView treeview;

    //  private new TreeViewModel model;
    public ProcessTreeView(TreeViewModel model) {
        // Constructor implementation

        // Set up the column view
        var m_model = (new Gtk.SingleSelection (model));

        treeview = new Gtk.ColumnView (m_model) {
            hexpand = true,
            vexpand = true,
        };
    }

    public void collapse_all() {
        // Method implementation
    }

    public void focus_on_child_row() {
        // Method implementation
    }

    public void focus_on_first_row () {
        // Method implementation
    }


}