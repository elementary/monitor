public class Monitor.ProcessInfoCPURAM : Gtk.Grid {
    private Gtk.Label cpu_label;
    private Gtk.Label ram_label;

    private Graph cpu_graph;
    private GraphModel cpu_graph_model;

    private Graph mem_graph;
    private GraphModel mem_graph_model;

    construct {
        column_spacing = 6;
        row_spacing = 6;
        vexpand = false;
        column_homogeneous = true;
        row_homogeneous = false;

        cpu_graph = new Graph ();
        mem_graph = new Graph ();

        var cpu_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        cpu_graph_box.get_style_context ().add_class ("graph");
        cpu_graph_box.add (cpu_graph);

        var mem_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        mem_graph_box.get_style_context ().add_class ("graph");
        mem_graph_box.add (mem_graph);

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

    public void update (Process process) {
        cpu_label.set_text (("CPU: %.1f%%").printf (process.cpu_percentage));
        ram_label.set_text (("RAM: %.1f%%").printf (process.mem_percentage));

        cpu_graph_model.update (process.cpu_percentage);
        cpu_graph.tooltip_text = ("%.1f%%").printf (process.cpu_percentage);

        mem_graph_model.update (process.mem_percentage);
        mem_graph.tooltip_text = ("%.1f%%").printf (process.mem_percentage);
    }

    public void clear_graphs () {
        cpu_graph_model = new GraphModel ();
        cpu_graph.set_model (cpu_graph_model);

        mem_graph_model = new GraphModel ();
        mem_graph.set_model (mem_graph_model);
    }
}