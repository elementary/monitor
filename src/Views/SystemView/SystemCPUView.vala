public class Monitor.SystemCPUView : Gtk.Grid {
    private Chart cpu_chart;
    private CPU cpu;

    private LabelVertical cpu_percentage_label;
    private LabelRoundy cpu_frequency_label;
    private LabelH4 processor_name_label;

    private Gtk.Button view_threads_usage_button;

    private Gtk.Revealer cpu_threads_revealer;

    private Gee.ArrayList<Gtk.Label?> core_label_list;

    construct {
        margin = 12;
        margin_top = 6;
        column_spacing = 12;
        set_vexpand (false);

        core_label_list = new Gee.ArrayList<Gtk.Label> ();
    }



    public SystemCPUView(CPU _cpu) {
        cpu = _cpu;

        cpu_percentage_label = new LabelVertical (_("UTILIZATION"));
        cpu_frequency_label = new LabelRoundy (_("FREQUENCY"));
        processor_name_label = new LabelH4 (cpu.cpu_name);

        cpu_chart = new Chart (cpu.core_list.size);

        cpu_percentage_label.clicked.connect(() => {
            cpu_threads_revealer.reveal_child = !(cpu_threads_revealer.child_revealed);
        });

        attach (processor_name_label, 0, 0, 1, 1);
        attach (grid_usage_labels(), 0, 1, 1, 1);
        attach (cpu_chart, 0, 1, 1, 1);
    }


    public void update () {
        for (int i = 0; i < cpu.core_list.size; i++) {
            double core_percentage = cpu.core_list[i].percentage_used;
            cpu_chart.update(i, core_percentage);
            string percentage_formatted = ("% 3d%%").printf ( (int)core_percentage);
            core_label_list[i].set_text (percentage_formatted);

            core_label_list[i].get_style_context ().remove_class ("core_badge-mild-warning");
            core_label_list[i].get_style_context ().remove_class ("core_badge-strong-warning");
            core_label_list[i].get_style_context ().remove_class ("core_badge-critical-warning");


            if (core_percentage > 75.0) {
                core_label_list[i].get_style_context ().add_class ("core_badge-mild-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-strong-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-critical-warning");
            }
            if (core_percentage > 85.0) {
                core_label_list[i].get_style_context ().add_class ("core_badge-strong-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-mild-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-critical-warning");
            }

            if (core_percentage > 90.0) {
                core_label_list[i].get_style_context ().add_class ("core_badge-critical-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-mild-warning");
                core_label_list[i].get_style_context ().remove_class ("core_badge-strong-warning");
            }
        }

        cpu_percentage_label.set_text ((_("%d%%")).printf (cpu.percentage));
        cpu_frequency_label.set_text (("%.2f %s").printf (cpu.frequency, _ ("GHz")));
    }

    private Gtk.Grid grid_info_labels () {
        Gtk.Grid grid = new Gtk.Grid ();

        grid.attach(processor_name_label, 0, 0, 1, 1);
        grid.attach(cpu_percentage_label, 0, 1, 1, 1);

        return grid;
    }

    private Gtk.Grid grid_usage_labels () {

        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 6;

        grid.attach(cpu_percentage_label, 0, 0, 1, 1);
        grid.attach(grid_core_labels(), 1, 0, 1, 1);

        return grid;
    }

    private Gtk.Revealer grid_core_labels () {
        cpu_threads_revealer = new Gtk.Revealer();
        cpu_threads_revealer.margin = 6;
        cpu_threads_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        cpu_threads_revealer.valign = Gtk.Align.CENTER;

        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 8;
        grid.row_spacing = 4;
        int column = 0;
        int row = 0;
        for (int i = 0; i < cpu.core_list.size; i++) {
            var core_label = new Gtk.Label (Utils.NO_DATA);
            core_label.get_style_context ().add_class ("core_badge");
            //  core_label.set_text (Utils.NO_DATA);
            core_label_list.add (core_label);

            grid.attach(core_label, column, row, 1, 1);

            row++;
            if (row > 1) {
                column++;
                row = 0;
            }
        }
        cpu_threads_revealer.add (grid);

        var threads_label = new Gtk.Label ("THREADS");
        threads_label.get_style_context ().add_class ("small-text");
        grid.attach(threads_label, 0, -1, column, 1);

        return cpu_threads_revealer;
    }
}