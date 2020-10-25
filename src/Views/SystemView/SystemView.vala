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

        add (cpu_view);
        add (memory_view);
        add (network_view);
        add (storage_view);
    }

    public void update () {
        cpu_view.update ();
        memory_view.update ();
        network_view.update ();
        storage_view.update ();
    }

}
