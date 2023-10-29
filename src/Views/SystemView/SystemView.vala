public class Monitor.SystemView : Gtk.Box {
    private Resources resources;

    private SystemCPUView cpu_view;
    private SystemMemoryView memory_view;
    private SystemNetworkView network_view;
    private SystemStorageView storage_view;
    private SystemGPUView gpu_view;

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

        var wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = wrapper
        };

        wrapper.append (cpu_view);
        wrapper.append (memory_view);
        wrapper.append (network_view);
        wrapper.append (storage_view);

        if (resources.gpu != null) {
            gpu_view = new SystemGPUView (resources.gpu);
            wrapper.append (gpu_view);
        }

        append (scrolled_window);
    }

    public void update () {
        cpu_view.update ();
        memory_view.update ();
        network_view.update ();
        storage_view.update ();
        if (resources.gpu != null) gpu_view.update ();
    }

}
