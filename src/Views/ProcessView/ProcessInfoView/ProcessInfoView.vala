public class Monitor.ProcessInfoView : Gtk.Box {
    private Process _process;
    public Process ? process {
        get { return _process; }
        set {
            _process = value;

            process_info_header.update (_process);
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

        process_info_header = new ProcessInfoHeader();
        add (process_info_header);

        var sep = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        sep.margin = 12;
        add (sep);


        cpu_graph = new Graph();
        mem_graph = new Graph();

        var graph_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        graph_wrapper.valign = Gtk.Align.START;
        graph_wrapper.height_request = 60;

        graph_wrapper.add (cpu_graph);
        graph_wrapper.add (mem_graph);

        add (graph_wrapper);

        var other_info_grid = new Gtk.Grid();
        other_info_grid.column_spacing = 12;

        var io_label = new Gtk.Label (_("IO"));
        io_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        var net_label = new Gtk.Label ( _("NET"));
        net_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);


        other_info_grid.attach (io_label, 0, 0, 1, 2);
        other_info_grid.attach (net_label, 1, 0, 1, 2);
        
        add (other_info_grid);

        var process_action_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        process_action_bar.valign = Gtk.Align.START;
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

        add (preventor);



    }

    public void update () {
        if (process != null) {
            process_info_header.update (process);

            cpu_graph_model.update (process.cpu_percentage);
            cpu_graph.tooltip_text = ("%.1f%%").printf (process.cpu_percentage);

            mem_graph_model.update (process.mem_percentage);
            mem_graph.tooltip_text = ("%.1f%%").printf (process.mem_percentage);

        }
    }



}