public class Monitor.SystemCPUView : Gtk.Box {
    private Chart cpu_utilization_chart;
    private Chart cpu_frequency_chart;
    private Chart cpu_temperature_chart;
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
        set_vexpand (false);
        orientation = Gtk.Orientation.VERTICAL;

        core_label_list = new Gee.ArrayList<Gtk.Label> ();
    }



    public SystemCPUView(CPU _cpu) {
        cpu = _cpu;

        cpu_percentage_label = new LabelVertical (_("UTILIZATION"));
        cpu_percentage_label.has_tooltip = true;
        cpu_percentage_label.tooltip_text = (_("Show detailed info"));
        cpu_frequency_label = new LabelRoundy (_("FREQUENCY"));
        cpu_frequency_label.margin = 6;

        processor_name_label = new LabelH4 (cpu.model_name);

        var processor_info_button = new Gtk.ToggleButton ();
        processor_info_button.get_style_context ().add_class ("circular");
        //  processor_info_button.get_style_context ().add_class ("popup");
        processor_info_button.has_focus = false;
        var icon = new Gtk.Image ();
        icon.gicon = new ThemedIcon ("dialog-information");
        icon.pixel_size = 16;
        processor_info_button.set_image (icon);
        processor_info_button.valign = Gtk.Align.START;
        processor_info_button.halign = Gtk.Align.START;


        var title_grid = new Gtk.Grid ();
        title_grid.attach (processor_name_label, 0, 0, 1, 1);
        title_grid.attach (processor_info_button, 1, 0, 1, 1);
        title_grid.column_spacing = 6;

        var popover = new SystemCPUInfoPopover (processor_info_button, cpu);
        
        processor_info_button.clicked.connect(() => { popover.show_all(); });

        cpu_utilization_chart = new Chart (cpu.core_list.size);

        var grid_utilization_info = new Gtk.Grid ();
        grid_utilization_info.attach (grid_usage_labels(), 0, 0, 1, 1);
        grid_utilization_info.attach (cpu_utilization_chart, 0, 0, 1, 1);


        
        cpu_frequency_chart = new Chart (1);
        cpu_frequency_chart.height_request = -1;
        cpu_frequency_chart.config.y_axis.fixed_max = 5.0;
        cpu_temperature_chart = new Chart (1);
        cpu_temperature_chart.margin_top = 6;
        cpu_temperature_chart.height_request = -1;

        var grid_frequency_info = new Gtk.Grid ();
        grid_frequency_info.attach (cpu_frequency_label, 0, 0, 1, 1);
        grid_frequency_info.attach (cpu_frequency_chart, 0, 0, 1, 1);


        cpu_percentage_label.clicked.connect(() => {
            cpu_threads_revealer.reveal_child = !(cpu_threads_revealer.child_revealed);

            if (cpu_threads_revealer.child_revealed) {
                cpu_percentage_label.tooltip_text = (_("Show detailed info"));
            } else {
                cpu_percentage_label.tooltip_text = (_("Hide detailed info"));
            }
        });

        var smol_charts_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        smol_charts_container.width_request = 200;
        smol_charts_container.hexpand = false;
        smol_charts_container.halign = Gtk.Align.START;
        smol_charts_container.add (grid_frequency_info);
        smol_charts_container.add (cpu_temperature_chart);
        smol_charts_container.margin_left = 6;

        // Thanks Goncalo
        var charts_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        charts_container.pack_start (grid_utilization_info, true, true, 0);
        charts_container.pack_start(smol_charts_container, false, false, 0);

        add (title_grid);
        add (charts_container);
    }


    public void update () {
        cpu_frequency_chart.update (0, cpu.frequency);

        for (int i = 0; i < cpu.core_list.size; i++) {
            double core_percentage = cpu.core_list[i].percentage_used;
            cpu_utilization_chart.update(i, core_percentage);
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

    private Gtk.Grid grid_usage_labels () {

        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin = 6;
        grid.valign = Gtk.Align.START;
        grid.halign = Gtk.Align.START;
        grid.get_style_context ().add_class ("usage-label-container");

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