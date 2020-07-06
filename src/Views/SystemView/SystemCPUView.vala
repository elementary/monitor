public class Monitor.SystemCPUView : Gtk.Grid {
    private SystemCPUChart cpu_chart;
    private CPU cpu;

    private Gtk.Label cpu_percentage_label;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);


    }



    public SystemCPUView(CPU _cpu) {
        cpu = _cpu;

        cpu_percentage_label = new Gtk.Label ("CPU: " + Utils.NO_DATA);
        cpu_percentage_label.get_style_context ().add_class ("h2");
        cpu_percentage_label.valign = Gtk.Align.START;

        cpu_chart = new SystemCPUChart (cpu.core_list.size);

        attach (cpu_percentage_label, 0, 0, 1, 2);
        attach (cpu_chart, 1, 0, 1, 1);
        
    }


    public void update () {
        for (int i = 0; i < cpu.core_list.size; i++) {
            cpu_chart.update(i, cpu.core_list[i].percentage_used);
        }

        cpu_percentage_label.set_text ((_("CPU: %d%%")).printf (cpu.percentage));
    }
}