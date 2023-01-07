public class Monitor.ContainerDetailedView : Gtk.Grid  {

    private DockerContainer _container;
    public DockerContainer ? container {
        get {
            return _container;
        }
        set {
            _container = value;
            clear_graphs ();
            set_charts_data (_container);
        }
    }

    private Gtk.Label cpu_label;
    private Gtk.Label ram_label;

    private Chart cpu_chart;
    private Chart ram_chart;

    construct {
        this.expand = true;
        this.width_request = 200;

        column_spacing = 6;
        row_spacing = 6;
        vexpand = false;
        column_homogeneous = true;
        row_homogeneous = false;

        cpu_chart = new Chart (1);
        cpu_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_300));
        ram_chart = new Chart (1);
        ram_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_300));

        cpu_chart.height_request = 60;
        ram_chart.height_request = 60;

        var cpu_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        cpu_graph_box.add (cpu_chart);

        var mem_graph_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
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

    public void set_charts_data (DockerContainer container) {
        cpu_chart.preset_data (0, container.cpu_percentage_history);
        ram_chart.preset_data (0, container.mem_percentage_history);
    }

    public void clear_graphs () {
        cpu_chart.clear ();
        ram_chart.clear ();
    }

    //  private Gtk.Widget build_container_name () {
    //      var container_name = new Gtk.Label (this.container.name);
    //      container_name.get_style_context ().add_class ("primary");
    //      container_name.halign = Gtk.Align.START;

    //      return container_name;
    //  }

    public void update () {
        cpu_label.set_text ((_("CPU: %.1f%%")).printf (0));
        ram_label.set_text ((_("RAM: %.1f%%")).printf (container.mem_percentage));

        //  cpu_chart.update (0, 0);
        ram_chart.update (0, container.mem_percentage);
    }
}