public class Monitor.ContainerSidebarView : Gtk.Box {
    private Gtk.ListBox listbox_containers = new Gtk.ListBox ();

    public signal void container_selected (DockerContainer container);


    construct {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.hexpand = true;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        var wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            expand = true
        };
        wrapper.add (listbox_containers);
        scrolled_window.add (wrapper);
        this.add (scrolled_window);

        GLib.ListStore model = new GLib.ListStore (typeof (DockerContainer));

        //  cursor_changed.connect (_cursor_changed);
        listbox_containers.row_selected.connect (this._row_selected);
    }


    public void insert (ref DockerContainer container) {
        //  if (conta)
        this.listbox_containers.foreach ((widget) => {
            remove(widget);
        });
        this.listbox_containers.insert (new ContainerSidebarItem (container), -1);
    }

    private void _row_selected () {
        ContainerSidebarItem row = (ContainerSidebarItem) this.listbox_containers.get_selected_row ();
        container_selected(row.container);
    }
}