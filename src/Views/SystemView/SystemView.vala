public class Monitor.SystemView : Gtk.Box {
    private SystemCPUChart cpu_chart;

    construct {
        cpu_chart = new SystemCPUChart (8);
    }

    public SystemView () {
        add (cpu_chart);
    }

    public void update (Resources resources) {
        for (int i = 0; i < resources.cpu.core_list.size; i++) {
            debug("%d", i);
            cpu_chart.update(i, resources.cpu.core_list[i].percentage_used);
        }

    }
}