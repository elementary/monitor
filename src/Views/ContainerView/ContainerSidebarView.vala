public class Monitor.ContainerSidebarView : Gtk.Box {
    private Gtk.ListBox listbox_containers = new Gtk.ListBox ();

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
    }

    public void insert (ref DockerContainer container) {
        this.listbox_containers.insert (new ContainerSidebarItem (container), -1);
    }
}