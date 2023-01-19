public class Monitor.ContainerInfoView : Gtk.Grid  {

    private DockerContainer _container;
    public DockerContainer ? container {
        get {
            return _container;
        }
        set {
            _container = value;
            this.container_charts.clear_graphs ();
            this.container_charts.set_charts_data (_container);
            this.container_header.update(container);
        }
    }

    private ContainerInfoHeader container_header = new ContainerInfoHeader ();
    private ContainerInfoCharts container_charts = new ContainerInfoCharts ();

    private Gtk.Label cpu_label;
    private Gtk.Label ram_label;

    construct {
        this.expand = false;
        this.width_request = 200;

        column_spacing = 6;
        row_spacing = 6;
        vexpand = false;
        margin = 12;
        column_homogeneous = true;
        row_homogeneous = false;

        cpu_label = new Gtk.Label ("CPU: " + Utils.NO_DATA);
        cpu_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        cpu_label.halign = Gtk.Align.START;

        ram_label = new Gtk.Label ("RAM: " + Utils.NO_DATA);
        ram_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        ram_label.halign = Gtk.Align.START;

        attach (container_header, 0, 0, 1, 1);
        attach (container_charts, 0, 1, 1, 1);
    }

    //  private Gtk.Widget build_container_name () {
    //      var container_name = new Gtk.Label (this.container.name);
    //      container_name.get_style_context ().add_class ("primary");
    //      container_name.halign = Gtk.Align.START;

    //      return container_name;
    //  }

    public void update () {
        if (container != null) {
            this.container_header.update(container);
            this.container_charts.update (container);
        }
    }
}