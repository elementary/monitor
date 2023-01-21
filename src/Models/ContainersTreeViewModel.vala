public enum Monitor.ContainerColumn {
    ICON,
    NAME,
    CPU,
    MEMORY,
    // STATE,
    ID
}

public class Monitor.ContainersTreeViewModel : Gtk.TreeStore {
    public ContainerManager container_manager;
    private Gee.HashMap<string, Gtk.TreeIter ? > container_rows = new Gee.HashMap<string, Gtk.TreeIter ? > ();
    private Gee.HashMap<string, Gtk.TreeIter ? > project_rows = new Gee.HashMap<string, Gtk.TreeIter ? > ();
    public signal void added_first_row ();

    construct {
        set_column_types (new Type[] {
            typeof (string),
            typeof (string),
            typeof (double),
            typeof (int64),
            typeof (string),
        });

        container_manager = ContainerManager.get_default ();

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



            if (container.compose_project != null) {
                if (!project_rows.has_key (container.compose_project)) {
                    Gtk.TreeIter parent_iter;
                    append (out parent_iter, null); // null means top-level
                    set (parent_iter,
                         ContainerColumn.ICON, "",
                         ContainerColumn.NAME, container.compose_project,
                         ContainerColumn.ID, Utils.NO_DATA,
                         // ContainerColumn.STATE, 0,
                         -1);
                    project_rows.set (container.compose_project, parent_iter);
                }
                Gtk.TreeIter child_iter;
                append (out child_iter, project_rows[container.compose_project]);
                set (child_iter,
                     ContainerColumn.ICON, "",
                     ContainerColumn.NAME, container.compose_service,
                     ContainerColumn.ID, container.id,
                     // ContainerColumn.STATE, 0,
                     -1);

                // add the process to our cache of process_rows
                container_rows.set (container.id, child_iter);

            } else {
                Gtk.TreeIter parent_iter;
                append (out parent_iter, null); // null means top-level
                set (parent_iter,
                     ContainerColumn.ICON, "",
                     ContainerColumn.NAME, container.name,
                     ContainerColumn.ID, container.id,
                     // ContainerColumn.STATE, 0,
                     -1);
                // add the process to our cache of process_rows
                container_rows.set (container.id, parent_iter);
            }


            if (container_rows.size < 1) {
                added_first_row ();
            }

            return true;
        }
        return false;
    }

    private void get_children_total (Gtk.TreeIter iter, ref int64 memory, ref double cpu) {
        // go through all children and add up CPU/Memory usage
        // TODO: this is a naive way to do things
        Gtk.TreeIter child_iter;

        if (iter_children (out child_iter, iter)) {
            do {
                get_children_total (child_iter, ref memory, ref cpu);
                Value cpu_value;
                Value memory_value;
                get_value (child_iter, Column.CPU, out cpu_value);
                get_value (child_iter, Column.MEMORY, out memory_value);
                memory += memory_value.get_int64 ();
                cpu += cpu_value.get_double ();
            } while (iter_next (ref child_iter));
        }
    }

    private void update_model () {
        foreach (string id in container_rows.keys) {
            DockerContainer container = container_manager.get_container (id);
            // debug("%s, %lld", container.name, container.mem_used);
            Gtk.TreeIter iter = container_rows[id];
            set (iter,
                 Column.CPU, container.cpu_percentage,
                 Column.MEMORY, container.mem_used,
                 -1);
        }
        var remove_me = new Gee.HashSet<string> ();
        foreach (var project in project_rows) {
            Gtk.TreeIter child_iter;
            var project_iter = project.value;

            if (!iter_children (out child_iter, project_iter)) {
                debug ("Project %s has no services! Will be removed.", project.key);
                remove (ref project_iter);
                remove_me.add (project.key);
                continue;
            }

            int64 total_mem = 0;
            double total_cpu = 0;
            this.get_children_total (project_iter, ref total_mem, ref total_cpu);
            set (project_iter,
                Column.CPU, total_cpu,
                Column.MEMORY, total_mem,
                -1);
        }

        foreach (string project_name in remove_me) {
            project_rows.unset (project_name);
        }
    }

    private void remove_container (string id) {
        // if process rows has pid
        if (container_rows.has_key (id)) {
            debug ("remove container %s from model".printf (id));
            var cached_iter = container_rows.get (id);
            remove (ref cached_iter);
            container_rows.unset (id);
        }
    }

}
