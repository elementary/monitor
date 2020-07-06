public class Monitor.SystemMemoryView : Gtk.Grid {
    //  private SystemChart memory_chart;
    private Memory memory;

    private Gtk.Label memory_percentage_label;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);

    }



    public SystemMemoryView(Memory _memory) {
        memory = _memory;

        memory_percentage_label = new Gtk.Label ("Memory: " + Utils.NO_DATA);
        memory_percentage_label.get_style_context ().add_class ("h2");
        memory_percentage_label.valign = Gtk.Align.START;
        memory_percentage_label.halign = Gtk.Align.START;

        //  memory_chart = new SystemCPUChart (memory.core_list.size);

        attach (memory_percentage_label, 0, 0, 1, 1);
        //  attach (grid_core_labels (), 0, 1, 1);
        //  attach (memory_chart, 1, 0, 1, 2);

    }


    public void update () {
        memory_percentage_label.set_text ((_("Memory: % 3d%%")).printf (memory.percentage));
    }

}