public class Monitor.SystemCPUView : Gtk.Grid {
    private SystemCPUChart cpu_chart;
    private CPU cpu;

    private Gtk.Label cpu_percentage_label;

    private Gee.ArrayList<Gtk.Label?> core_label_list;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);

        core_label_list = new Gee.ArrayList<Gtk.Label> ();
    }



    public SystemCPUView(CPU _cpu) {
        cpu = _cpu;

        cpu_percentage_label = new Gtk.Label (_("CPU: ") + Utils.NO_DATA);
        cpu_percentage_label.get_style_context ().add_class ("h2");
        cpu_percentage_label.valign = Gtk.Align.START;
        cpu_percentage_label.halign = Gtk.Align.START;
        cpu_percentage_label.margin_start = 6;

        cpu_chart = new SystemCPUChart (cpu.core_list.size);

        attach (grid_core_labels (), 0, 0, 1);
        attach (cpu_percentage_label, 1, 0, 1, 1);
        attach (cpu_chart, 1, 0, 1, 2);
        
    }


    public void update () {
        for (int i = 0; i < cpu.core_list.size; i++) {
            double core_percentage = cpu.core_list[i].percentage_used;
            cpu_chart.update(i, core_percentage);
            string percentage_formatted = ("% 3d%%").printf ( (int)core_percentage);
            core_label_list[i].set_text (_("Thread %d: %s".printf (i, percentage_formatted)));
        }

        cpu_percentage_label.set_text ((_("CPU: % 3d%%")).printf (cpu.percentage));
    }

    private Gtk.Grid grid_core_labels () {
        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.width_request = 300;
        int column = 0;
        int row = 0;
        for (int i = 0; i < cpu.core_list.size; i++) {
            var core_label = new Gtk.Label(_("Thread %d: ".printf (i)) + Utils.NO_DATA);
            core_label.halign = Gtk.Align.START;
            core_label_list.add (core_label);

            grid.attach(core_label, column, row, 1, 1);

            column++;
            if (column > 1) {
                row++;
                column = 0;
            }
        }

        return grid;
    }
}