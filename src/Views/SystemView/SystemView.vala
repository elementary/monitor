public class Monitor.SystemView : Gtk.Box {
    private Resources resources;

    private SystemCPUView cpu_view;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;


    }

    public SystemView (Resources _resources) {
        resources = _resources;

        cpu_view = new SystemCPUView (resources.cpu);

        add (cpu_view);
    }

    public void update () {
        cpu_view.update();
    }
}