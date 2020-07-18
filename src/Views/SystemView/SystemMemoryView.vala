public class Monitor.SystemMemoryView : Gtk.Grid {
    private SystemCPUChart memory_chart;
    private Memory memory;

    private Gtk.Label memory_percentage_label;
    private Gtk.Label memory_shared_label;
    private Gtk.Label memory_buffered_label;
    private Gtk.Label memory_cached_label;
    private Gtk.Label memory_locked_label;
    private Gtk.Label memory_total_label;
    private Gtk.Label memory_used_label;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);
    }



    public SystemMemoryView(Memory _memory) {
        memory = _memory;

        memory_percentage_label = new Gtk.Label ("Memory: " + Utils.NO_DATA);
        memory_percentage_label.get_style_context ().add_class ("h2");
        memory_percentage_label.halign = Gtk.Align.START;
        memory_percentage_label.valign = Gtk.Align.START;
        memory_percentage_label.margin_start = 6;

        memory_total_label = new Gtk.Label ("Total: " + Utils.NO_DATA);
        memory_total_label.halign = Gtk.Align.START;

        memory_used_label = new Gtk.Label ("Used: " + Utils.NO_DATA);
        memory_used_label.halign = Gtk.Align.START;

        memory_shared_label = new Gtk.Label ("Shared: " + Utils.NO_DATA);
        memory_shared_label.halign = Gtk.Align.START;

        memory_buffered_label = new Gtk.Label ("Buffered: " + Utils.NO_DATA);
        memory_buffered_label.halign = Gtk.Align.START;

        memory_cached_label = new Gtk.Label ("Cached: " + Utils.NO_DATA);
        memory_cached_label.halign = Gtk.Align.START;

        memory_locked_label = new Gtk.Label ("Locked: " + Utils.NO_DATA);
        memory_locked_label.halign = Gtk.Align.START;

        memory_chart = new SystemCPUChart (1);

        attach (memory_percentage_label, 1, 0, 1, 1);
        attach (memory_usage_grid (), 0, 0, 1);
        attach (memory_chart, 1, 0, 1, 2);

    }

    private Gtk.Grid memory_usage_grid () {
        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.width_request = 300;

        grid.attach (memory_used_label, 0, 0, 1, 1);
        grid.attach (memory_total_label, 1, 0, 1, 1);
        grid.attach (memory_shared_label, 0, 1, 1, 1);
        grid.attach (memory_buffered_label, 1, 1, 1, 1);
        grid.attach (memory_cached_label, 0, 2, 1, 1);
        grid.attach (memory_locked_label, 1, 2, 1, 1);

        return grid;
    }


    public void update () {
        memory_percentage_label.set_text ((_("Memory: % 3d%%")).printf (memory.percentage));
        memory_chart.update (0, memory.percentage);

        memory_total_label.set_text ((_("Total: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.total)));
        memory_used_label.set_text ((_("Used: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.used)));
        memory_shared_label.set_text ((_("Shared: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.shared)));
        memory_buffered_label.set_text ((_("Buffered: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.buffer)));
        memory_cached_label.set_text ((_("Cached: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.cached)));
        memory_locked_label.set_text ((_("Locked: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.locked)));
    }

}