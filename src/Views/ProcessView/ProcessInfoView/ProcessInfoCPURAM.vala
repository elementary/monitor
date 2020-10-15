public class Monitor.ProcessInfoCPURAM : Gtk.Grid {
    private Gtk.Label cpu_label;
    private Gtk.Label ram_label;

    private ProcessChart cpu_chart;
    private ProcessChart ram_chart;

    construct {
        column_spacing = 6;
        row_spacing = 6;
        vexpand = false;
        column_homogeneous = true;
        row_homogeneous = false;

        cpu_chart = new ProcessChart ();
        ram_chart = new ProcessChart ();


        var cpu_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        cpu_graph_box.get_style_context ().add_class ("graph");
        cpu_graph_box.add (cpu_chart);



        var mem_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        mem_graph_box.get_style_context ().add_class ("graph");
        mem_graph_box.add (ram_chart);

        cpu_label = new Gtk.Label ("CPU: " + Utils.NO_DATA);
        cpu_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        cpu_label.halign = Gtk.Align.START;

        ram_label = new Gtk.Label ("RAM: " + Utils.NO_DATA);
        ram_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        ram_label.halign = Gtk.Align.START;

        attach (cpu_label, 0, 0, 1, 1);
        attach (ram_label, 1, 0, 1, 1);

        attach (cpu_graph_box, 0, 1, 1, 1);
        attach (mem_graph_box, 1, 1, 1, 1);
    }

    public void set_charts_data (Process process) {
        cpu_chart.set_data (process.cpu_percentage_history);
        ram_chart.set_data (process.mem_percentage_history);
    }

    public void update (Process process) {
        cpu_label.set_text ((_("CPU: %.1f%%")).printf (process.cpu_percentage));
        ram_label.set_text ((_("RAM: %.1f%%")).printf (process.mem_percentage));

        cpu_chart.update(process.cpu_percentage);
        ram_chart.update(process.mem_percentage);

    }

    public void clear_graphs () {
        cpu_chart.clear ();
        ram_chart.clear ();
    }
}