
public class Monitor.ProcessTreeView : Granite.Bin {
    private Gtk.ColumnView list;

    // private new TreeViewModel model;
    public ProcessTreeView (TreeViewModel model) {

        //  model = new Gtk.TreeListModel();
        // Constructor implementation

        var mmodel = new GLib.ListStore (typeof (ProcessRow));

        var sorted_sensors = new Gtk.SortListModel (mmodel, null);

        mmodel.append (new ProcessRow () { name = "test" });
        mmodel.append (new ProcessRow () { name = "test2" });

        list = new Gtk.ColumnView (new Gtk.NoSelection (sorted_sensors)) {
            name = "sensors",
            reorderable = false,
            hexpand = false,
            vexpand = true
        };

        var row_factory = new Gtk.SignalListItemFactory ();

        row_factory.setup.connect ((factory, obj) => {
            var row = obj as Gtk.ColumnViewRow;
            row.focusable = false;
            row.activatable = false;
        });

        list.row_factory = row_factory;

        child = list;


        var proc_name_factory = new Gtk.SignalListItemFactory ();
        proc_name_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label ("") {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        proc_name_factory.bind.connect((factory, obj) => {
                var cell = obj as Gtk.ColumnViewCell;
                var label = cell.child as Gtk.Label;
                var item = cell.item as ProcessRow;
                debug (item.name);
                label.set_text (item.name);
            });

        var proc_name_column = new Gtk.ColumnViewColumn (_("Process Name"), proc_name_factory);
        list.append_column (proc_name_column);
        // list.append_column (new Gtk.ColumnViewColumn ("Chip", chipname_factory) {
        // sorter = str_sorter ("chip_label")
        // });
        // list.append_column (new Gtk.ColumnViewColumn ("Feature", feature_factory) {
        // sorter = str_sorter ("feature_label")
        // });
        // list.append_column (new Gtk.ColumnViewColumn ("Value", value_factory) {
        // sorter = num_sorter ("value"), expand = true
        // });
        // list.append_column (new Gtk.ColumnViewColumn ("", remove_factory));
    }

    public void collapse_all () {
        // Method implementation
    }

    public void focus_on_child_row () {
        // Method implementation
    }

    public void focus_on_first_row () {
        // Method implementation
    }

}
