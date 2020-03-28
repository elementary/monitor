public class Monitor.ProcessInfoView : Gtk.Grid {
    private Process _process;
    public Process ? process {
        get { return _process; }
        set {
            _process = value;

            process_info_header.update (_process);
            process_info_io_stats.update (_process);

            process_info_cpu_ram.clear_graphs ();

        }
    }
    public string ? icon_name;
    private Gtk.ScrolledWindow command_wrapper;

    private ProcessInfoHeader process_info_header;
    private ProcessInfoIOStats process_info_io_stats;
    private ProcessInfoCPURAM process_info_cpu_ram;
    
    private Regex ? regex;
    private Gtk.Grid grid;



    private Gtk.Button end_process_button;
    private Gtk.Button kill_process_button;

    private Preventor preventor;

    public ProcessInfoView () {
        //  get_style_context ().add_class ("process_info");
        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
        column_spacing = 12;

        process_info_header = new ProcessInfoHeader();
        attach (process_info_header, 0, 0, 1, 1);

        var sep = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        sep.margin = 12;
        attach (sep, 0, 1, 1, 1);

        process_info_cpu_ram = new ProcessInfoCPURAM ();

        attach (process_info_cpu_ram, 0, 2, 1, 1);

        process_info_io_stats = new ProcessInfoIOStats ();
        attach (process_info_io_stats, 0, 4, 1, 1);


        var process_action_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        process_action_bar.valign = Gtk.Align.END;
        process_action_bar.halign = Gtk.Align.END;
        
        end_process_button = new Gtk.Button.with_label (_("End Process"));
        end_process_button.margin_end = 10;
        end_process_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>E"}, _("End selected process"));
        var end_process_button_context = end_process_button.get_style_context ();
        end_process_button_context.add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        kill_process_button = new Gtk.Button.with_label (_("Kill Process"));
        kill_process_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>K"}, _("Kill selected process"));
        var kill_process_button_context = kill_process_button.get_style_context ();
        kill_process_button_context.add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        process_action_bar.add (end_process_button);
        process_action_bar.add (kill_process_button);

        Preventor preventor = new Preventor (process_action_bar, "process_action_bar");

        kill_process_button.clicked.connect(() => {
            preventor.set_prevention (_("Confirm kill of the process?"));
            preventor.confirmed.connect((is_confirmed) => {
                if (is_confirmed) process.kill(); // maybe add a toast that process killed
            });
        });

        end_process_button.clicked.connect(() => {
            preventor.set_prevention (_("Confirm end of the process?"));
            preventor.confirmed.connect((is_confirmed) => {
                if (is_confirmed) process.end(); // maybe add a toast that process ended
           });
        });

        attach (preventor, 0, 5, 1, 1);



    }

    public void update () {
        if (process != null) {
            process_info_header.update (process);
            process_info_cpu_ram.update (process);
        }
    }



}