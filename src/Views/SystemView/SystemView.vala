public class Monitor.SystemView : Gtk.Box {
    private SystemCPUChart cpu_chart;
    private Resources resources;

    construct {
        
    }

    public SystemView (Resources _resources) {
        resources = _resources;
        cpu_chart = new SystemCPUChart (resources.cpu.core_list.size);

        add (cpu_chart);
    }

    public void update () {
        for (int i = 0; i < resources.cpu.core_list.size; i++) {
            debug("%d", i);
            cpu_chart.update(i, resources.cpu.core_list[i].percentage_used);
        }

    }
}