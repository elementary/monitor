public class Monitor.ProcessInfoView : Gtk.Grid {
    private Process _process;
    public Process ? process {
        get { return _process; }
        set {
            _process = value;

            process_info_header.update (_process);
            process_info_other.update (_process);
            // Clearing graphs when new process is set
            cpu_graph_model = new GraphModel();
            cpu_graph.set_model(cpu_graph_model);

            mem_graph_model = new GraphModel();
            mem_graph.set_model(mem_graph_model);
        }
    }
    public string ? icon_name;
    private Gtk.ScrolledWindow command_wrapper;

    private ProcessInfoHeader process_info_header;
    private ProcessInfoOther process_info_other;
    
    private Regex ? regex;
    private Gtk.Grid grid;

    private Graph cpu_graph;
    private GraphModel cpu_graph_model;

    private Graph mem_graph;
    private GraphModel mem_graph_model;

    private Gtk.Button end_process_button;
    private Gtk.Button kill_process_button;

    private Preventor preventor;

    construct {
        cpu_graph_model = new GraphModel();
    }

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


        cpu_graph = new Graph();
        mem_graph = new Graph();

        var graph_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        graph_wrapper.vexpand = false;
        graph_wrapper.height_request = 60;

        graph_wrapper.add (cpu_graph);
        graph_wrapper.add (mem_graph);

        attach (graph_wrapper, 0, 2, 1, 1);

        process_info_other = new ProcessInfoOther ();
        attach (process_info_other, 0, 3, 1, 1);

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

        attach (preventor, 0, 4, 1, 1);



    }

    public void update () {
        if (process != null) {
            process_info_header.update (process);
            process_info_other.update (process);

            cpu_graph_model.update (process.cpu_percentage);
            cpu_graph.tooltip_text = ("%.1f%%").printf (process.cpu_percentage);

            mem_graph_model.update (process.mem_percentage);
            mem_graph.tooltip_text = ("%.1f%%").printf (process.mem_percentage);

        }
    }



}