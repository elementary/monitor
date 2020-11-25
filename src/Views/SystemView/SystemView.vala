public class Monitor.SystemView : Gtk.Box {
    private Resources resources;

    private SystemCPUView cpu_view;
    private SystemMemoryView memory_view;
    private SystemNetworkView network_view;
    private SystemStorageView storage_view;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
    }

    public SystemView (Resources _resources) {
        resources = _resources;

        cpu_view = new SystemCPUView (resources.cpu);
        memory_view = new SystemMemoryView (resources.memory);
        network_view = new SystemNetworkView (resources.network);
        storage_view = new SystemStorageView (resources.storage);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        var wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        wrapper.expand = true;
        scrolled_window.add (wrapper);


        wrapper.add (cpu_view);
        wrapper.add (memory_view);
        wrapper.add (network_view);
        wrapper.add (storage_view);

        add (scrolled_window);
    }

    public void update () {
        cpu_view.update ();
        memory_view.update ();
        network_view.update ();
        storage_view.update ();
    }

}
