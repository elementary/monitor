public class Monitor.SystemCPUView : Gtk.Grid {
    private SystemCPUChart cpu_chart;
    private CPU cpu;

    private VerticalLabel cpu_percentage_label;
    private Gtk.Label processor_name_label;

    private Gtk.Button view_threads_usage_button;

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

        cpu_percentage_label = new VerticalLabel (_("UTILIZATION"));
        //  cpu_percentage_label.get_style_context ().add_class ("h3");
        //  cpu_percentage_label.valign = Gtk.Align.START;
        //  cpu_percentage_label.halign = Gtk.Align.START;
        //  cpu_percentage_label.margin_start = 12;
        //  cpu_percentage_label.margin_top = 6;

        processor_name_label = new Gtk.Label ("AMD Ryzen 5 2400G with Radeon Vega Graphics");
        processor_name_label.get_style_context ().add_class ("h4");
        //  processor_name_label.get_style_context ().add_class ("text-secondary");
        processor_name_label.valign = Gtk.Align.START;
        processor_name_label.halign = Gtk.Align.START;
        processor_name_label.margin_start = 6;
        //  processor_name_label.margin_top = 6;

        cpu_chart = new SystemCPUChart (cpu.core_list.size);

        view_threads_usage_button = new Gtk.Button ();
        view_threads_usage_button.has_tooltip = true;
        view_threads_usage_button.tooltip_text = (_("Settings"));
        var icon = new Gtk.Image ();
        icon.gicon = new ThemedIcon ("view-more-horizontal-symbolic");
        icon.pixel_size = 16;
        view_threads_usage_button.set_image (icon);

        //  attach (grid_core_labels (), 0, 0, 1, 1);
        //  attach (grid_info_labels (), 0, 0, 1, 1);
        attach (processor_name_label, 0, 0, 1, 1);
        attach (grid_usage_labels(), 0, 1, 1, 1);
        //  attach (view_threads_usage_button, 1, 1, 1, 1);
        //  attach (processor_name_label, 0, 0, 1, 1);
        attach (cpu_chart, 0, 1, 1, 1);
        
    }


    public void update () {
        for (int i = 0; i < cpu.core_list.size; i++) {
            double core_percentage = cpu.core_list[i].percentage_used;
            cpu_chart.update(i, core_percentage);
            string percentage_formatted = ("% 3d%%").printf ( (int)core_percentage);
            //  core_label_list[i].set_text (_("Thread %d: %s").printf (i, percentage_formatted));
        }

        cpu_percentage_label.set_text ((_("%d%%")).printf (cpu.percentage));
    }

    private Gtk.Grid grid_info_labels () {
        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;

        grid.attach(processor_name_label, 0, 0, 1, 1);
        grid.attach(cpu_percentage_label, 0, 1, 1, 1);

        return grid;
    }

    private Gtk.Grid grid_usage_labels () {
        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;

        grid.attach(cpu_percentage_label, 0, 0, 1, 1);
        //  grid.attach(view_threads_usage_button, 1, 0, 1, 1);

        return grid;
    }

    private Gtk.Grid grid_core_labels () {
        Gtk.Grid grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.width_request = 300;
        int column = 0;
        int row = 0;
        for (int i = 0; i < cpu.core_list.size; i++) {
            var core_label = new Gtk.Label(_("Thread %d: ").printf (i) + Utils.NO_DATA);
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