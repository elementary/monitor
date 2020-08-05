public class Monitor.SystemMemoryView : Gtk.Grid {
    private Chart memory_chart;
    private Memory memory;

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



    public SystemMemoryView(Memory _memory) {
        memory = _memory;

        memory_name_label = new LabelH4 (_("Memory"));

        memory_percentage_label = new LabelVertical (_("UTILIZATION"));

        memory_percentage_label.clicked.connect(() => {
            memory_usage_revealer.reveal_child = !(memory_usage_revealer.child_revealed);
        });

        memory_total_label = new Gtk.Label (_("Total: ") + Utils.NO_DATA);
        memory_total_label.halign = Gtk.Align.START;

        memory_used_label = new Gtk.Label (_("Used: ") + Utils.NO_DATA);
        memory_used_label.halign = Gtk.Align.START;

        memory_shared_label = new Gtk.Label (_("Shared: ") + Utils.NO_DATA);
        memory_shared_label.halign = Gtk.Align.START;

        memory_buffered_label = new Gtk.Label (_("Buffered: ") + Utils.NO_DATA);
        memory_buffered_label.halign = Gtk.Align.START;

        memory_cached_label = new Gtk.Label (_("Cached: ") + Utils.NO_DATA);
        memory_cached_label.halign = Gtk.Align.START;

        memory_locked_label = new Gtk.Label (_("Locked: ") + Utils.NO_DATA);
        memory_locked_label.halign = Gtk.Align.START;

        memory_chart = new Chart (1);

        var lil_gridy = new Gtk.Grid ();
        lil_gridy.attach (memory_percentage_label, 0, 0, 1, 1);
        lil_gridy.attach (memory_usage_grid (), 1, 0, 1, 1);

        attach (memory_name_label, 0, 0, 1, 1);
        attach (lil_gridy, 0, 1, 1, 1);
        attach (memory_chart, 0, 1, 2, 2);

    }

    private Gtk.Revealer memory_usage_grid () {
        memory_usage_revealer = new Gtk.Revealer();
        memory_usage_revealer.margin = 6;
        memory_usage_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        memory_usage_revealer.valign = Gtk.Align.CENTER;

        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.width_request = 300;

        grid.attach (memory_used_label, 0, 0, 1, 1);
        grid.attach (memory_total_label, 1, 0, 1, 1);
        grid.attach (memory_shared_label, 0, 1, 1, 1);
        grid.attach (memory_buffered_label, 1, 1, 1, 1);
        grid.attach (memory_cached_label, 0, 2, 1, 1);
        grid.attach (memory_locked_label, 1, 2, 1, 1);

        memory_usage_revealer.add (grid);

        return memory_usage_revealer;
    }


    public void update () {
        memory_percentage_label.set_text ((_("%d%%")).printf (memory.percentage));
        memory_chart.update (0, memory.percentage);

        memory_total_label.set_text ((_("Total: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.total)));
        memory_used_label.set_text ((_("Used: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.used)));
        memory_shared_label.set_text ((_("Shared: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.shared)));
        memory_buffered_label.set_text ((_("Buffered: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.buffer)));
        memory_cached_label.set_text ((_("Cached: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.cached)));
        memory_locked_label.set_text ((_("Locked: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human(memory.locked)));
    }

}