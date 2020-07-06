public class Monitor.SystemView : Gtk.Box {
    private Resources resources;

    private SystemCPUView cpu_view;
    private SystemMemoryView memory_view;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;


    }

    public SystemView (Resources _resources) {
        resources = _resources;

        cpu_view = new SystemCPUView (resources.cpu);
        memory_view = new SystemMemoryView (resources.memory);

        add (cpu_view);
        add (memory_view);
    }

    public void update () {
        cpu_view.update();
        memory_view.update();
    }
}