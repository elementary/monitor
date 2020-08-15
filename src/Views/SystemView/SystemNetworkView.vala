public class Monitor.SystemNetworkView : Gtk.Grid {
    private Chart network_chart;
    private Network network;

    private LabelH4 memory_name_label;
    private LabelVertical memory_percentage_label;
    private Gtk.Label memory_shared_label;
    private Gtk.Label memory_buffered_label;
    private Gtk.Label memory_cached_label;
    private Gtk.Label memory_locked_label;
    private Gtk.Label memory_total_label;
    private Gtk.Label memory_used_label;
    private Gtk.Revealer memory_usage_revealer;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);
    }



    public SystemNetworkView(Network _network) {
        network = _network;

        memory_name_label = new LabelH4 (_("Network"));

       network_chart = new Chart (1);



        attach (memory_name_label, 0, 0, 1, 1);
        attach (network_chart, 0, 1, 2, 2);

    }

    private Gtk.Revealer memory_usage_grid () {

        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.width_request = 300;

        return memory_usage_revealer;
    }


    public void update () {
        //  network_chart.update (0, network);

    }

}