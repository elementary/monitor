
public class Monitor.OpenFilesTreeViewModel : Gtk.TreeStore {
    private Gee.Map<string, Gtk.TreeIter ? > open_files_paths = new Gee.HashMap<string, Gtk.TreeIter ? > ();
    
    private Process _process;

    public Process ? process {
        get {
            return _process;
        }
        set {
            _process = value;

            // repopulating
            open_files_paths.clear ();
            clear ();
            add_paths ();
        }
    }

    construct {
        set_column_types (new Type[] {
            typeof (string),
            typeof (string),
        });

    }

    public void add_paths () {
        foreach (var path in process.open_files_paths) {
            add_path (path);
        }
        debug("Added paths: %d", open_files_paths.size);
    }



    private bool add_path (string path) {
        if (path.substring (0, 1) == "/") {
            Gtk.TreeIter iter;
            append (out iter, null);

            set (iter,
                Column.NAME, path,
                -1);

            //  open_files_paths.set (path, iter);
            return true;
        }
        return false;
    }

    public void update_model (Process process) {
        if (process.open_files_paths.size > 0) {
            foreach (var path in process.open_files_paths) {

                //  print("sdsd");
                //  Gtk.TreeIter iter = open_files_paths[path];
                print (path);
                //  // display only real paths
                //  // probably should be done in process class
                //  if (path.substring (0, 1) == "/") {
                //      set (iter,
                //          Column.NAME, path,
                //          -1);
                //  }
            }
        }
    }


}
