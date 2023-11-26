public class Monitor.ProcessInfoView : Gtk.Box {
    private Preventor preventor;
    private ProcessInfoIOStats process_info_io_stats = new ProcessInfoIOStats ();

    private Process _process;
    public Process ? process {
        get {
            return _process;
        }
        set {
            // remember to disconnect before assigning a new value
            if (_process != null) {
                _process.fd_permission_error.disconnect (show_permission_error_infobar);
            }
            _process = value;

            process_info_header.update (_process);

            // this.show_all ();
            if (_process.uid != Posix.getuid ()) {
                process_info_cpu_ram.hide ();
                process_info_io_stats.hide ();
                end_process_button.hide ();
                kill_process_button.hide ();
                preventor.hide ();
            } else {
                _process.fd_permission_error.connect (show_permission_error_infobar);

                process_info_io_stats.update (_process);

                process_info_cpu_ram.clear_graphs ();
                process_info_cpu_ram.set_charts_data (_process);

                permission_error_infobar.revealed = false;

                process_info_io_stats.open_files_tree_view.model.process = _process;
                process_info_io_stats.open_files_tree_view.set_visible (true);
                process_info_cpu_ram.set_visible (true);
                process_info_io_stats.set_visible (true);
                end_process_button.show ();
                kill_process_button.show ();
                preventor.show ();
            }
        }
    }
    public string ? icon_name;

    private Gtk.InfoBar permission_error_infobar;
    private Gtk.Label permission_error_label;

    private ProcessInfoHeader process_info_header;
    private ProcessInfoCPURAM process_info_cpu_ram;

    private Gtk.Button end_process_button;
    private Gtk.Button kill_process_button;

    public ProcessInfoView () {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;

        permission_error_infobar = new Gtk.InfoBar ();
        permission_error_infobar.message_type = Gtk.MessageType.ERROR;
        permission_error_infobar.revealed = false;
        permission_error_label = new Gtk.Label (Utils.NO_DATA);
        permission_error_infobar.add_child (permission_error_label);
        // append (permission_error_infobar);

        var grid = new Gtk.Grid () {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            hexpand = true,
            column_spacing = 12
        };

        process_info_header = new ProcessInfoHeader ();
        grid.attach (process_info_header, 0, 0, 1, 1);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            hexpand = true
        };
        grid.attach (separator, 0, 1, 1, 1);

        process_info_cpu_ram = new ProcessInfoCPURAM ();
        grid.attach (process_info_cpu_ram, 0, 2, 1, 1);

        grid.attach (process_info_io_stats, 0, 4, 1, 1);


        var process_action_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 12,
            margin_bottom = 12,
            margin_end = 12,
            valign = Gtk.Align.END,
            halign = Gtk.Align.END
        };

        end_process_button = new Gtk.Button.with_label (_("End Process"));
        end_process_button.margin_end = 10;
        end_process_button.tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>E" }, _("End selected process"));
        var end_process_button_context = end_process_button.get_style_context ();
        end_process_button_context.add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        kill_process_button = new Gtk.Button.with_label (_("Kill Process"));
        kill_process_button.tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>K" }, _("Kill selected process"));
        var kill_process_button_context = kill_process_button.get_style_context ();
        kill_process_button_context.add_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        process_action_bar.append (end_process_button);
        process_action_bar.append (kill_process_button);

        append (grid);

        preventor = new Preventor (process_action_bar, "process_action_bar");
        grid.attach (preventor, 0, 5, 1, 1);
        preventor.hide ();


        kill_process_button.clicked.connect (() => {
            preventor.set_prevention (_("Confirm kill of the process?"));
            preventor.confirmed.connect ((is_confirmed) => {
                if (is_confirmed) process.kill (); // maybe add a toast that process killed
            });
        });

        end_process_button.clicked.connect (() => {
            preventor.set_prevention (_("Confirm end of the process?"));
            preventor.confirmed.connect ((is_confirmed) => {
                if (is_confirmed) process.end (); // maybe add a toast that process ended
            });
        });

    }

    private void show_permission_error_infobar (string error) {
        if (permission_error_infobar.revealed == false) {
            permission_error_label.set_text (error);
            permission_error_infobar.revealed = true;
        }
    }

    public void update () {
        if (process != null) {
            process_info_header.update (process);
            process_info_cpu_ram.update (process);
            process_info_io_stats.update (process);

            process_info_io_stats.open_files_tree_view.model.process = _process;
            process_info_io_stats.open_files_tree_view.set_visible (true);
        }
    }

}
