public enum Monitor.ContainerColumn {
    ICON,
    NAME,
    CPU,
    MEMORY,
    //  STATE,
    ID
}

public class Monitor.ContainersTreeViewModel : Gtk.TreeStore {
    public ContainerManager container_manager = new ContainerManager ();
    private Gee.HashMap<string, Gtk.TreeIter ? > container_rows = new Gee.HashMap<string, Gtk.TreeIter ? > ();
    public signal void added_first_row ();

    construct {
        set_column_types (new Type[] {
            typeof (string),
            typeof (string),
            typeof (double),
            typeof (int64),
            typeof (string),
        });

        container_manager.updated.connect (update_model);
        container_manager.container_added.connect ((container) => add_container (container));
        container_manager.container_removed.connect ((id) => remove_container (id));

        Idle.add (() => { add_running_containers (); return false; });
    }

    private void add_running_containers () {
        debug ("add_running_containers");
        var containers = container_manager.get_container_list ();
        foreach (var container in containers.values) {
            add_container (container);
        }
    }

    private bool add_container (DockerContainer container) {
        if (container != null && !container_rows.has_key (container.id)) {
            debug ("Add container %s %s", container.name, container.id);
            // add the process to the model
            Gtk.TreeIter iter;
            append (out iter, null); // null means top-level

            // donno what is going on, but maybe just use a string insteead of Icon ??
            // coz it lagz
            // string icon_name = process.icon.to_string ();

            set (iter,
                ContainerColumn.ICON, "",
                 ContainerColumn.NAME, container.name,
                 ContainerColumn.ID, container.id,
                //   ContainerColumn.STATE, 0,
                 -1);
            if (container_rows.size < 1) {
                added_first_row ();
            }
            // add the process to our cache of process_rows
            container_rows.set (container.id, iter);
            return true;
        }
        return false;
    }

    private void update_model () {
        foreach (string id in container_rows.keys) {
            DockerContainer container = container_manager.get_container (id);
            //  debug("%s, %lld", container.name, container.mem_used);
            Gtk.TreeIter iter = container_rows[id];
            set (iter,
                 Column.CPU, container.cpu_percentage,
                 Column.MEMORY, container.mem_used,
                 -1);
        }
    }

    private void remove_container (string id) {
        // if process rows has pid
        if (container_rows.has_key (id)) {
            debug ("remove container %s from model".printf (id));
            //  var cached_iter = container_rows.get (id);
            //  remove (ref cached_iter);
            container_rows.unset (id);
        }
    }

}
