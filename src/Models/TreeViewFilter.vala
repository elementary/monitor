public class Monitor.TreeViewFilter : GLib.Object {
    private string _needle;
    public string needle {
        get {
            return _needle;
        }
        set {
            name_filter.search = value;
            cmd_filter.search = value;
            _needle = value;
        }
    }
    public Gtk.FilterListModel model_out;
    private Gtk.AnyFilter any_filter;
    public Gtk.StringFilter name_filter;
    public Gtk.StringFilter cmd_filter;
    public Gtk.CustomFilter pid_filter;

    public TreeViewFilter (GLib.ListModel? model) {
        name_filter = build_str_filter ("name");
        cmd_filter = build_str_filter ("cmd");

        // since the pid property is an int, we need to use a custom filter to convert it to a string
        pid_filter = new Gtk.CustomFilter ((obj) => {
            var item = (ProcessRowData) obj;
            bool pid_found = item.pid.to_string ().contains (needle.casefold ()) || false;
            return pid_found;
        });

        any_filter = new Gtk.AnyFilter ();
        any_filter.append (name_filter);
        any_filter.append (cmd_filter);
        any_filter.append (pid_filter);

        model_out = new Gtk.FilterListModel (model, any_filter);

    }

    private Gtk.StringFilter build_str_filter (string column_name) {
        var expression = new Gtk.PropertyExpression (typeof (ProcessRowData), null, column_name);
        return new Gtk.StringFilter (expression) {
            ignore_case = true,
            match_mode = SUBSTRING,
            search = needle
        };
    }

}