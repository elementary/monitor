public class Monitor.ProcessInfoView : Gtk.Box {
    public Gtk.Label application_name;
    public string ? icon_name;
    public Gtk.TextView command;
    private Gtk.ScrolledWindow command_wrapper;
    public Gtk.Label pid;
    public Gtk.Label ppid;
    public Gtk.Label pgrp;
    public Gtk.Label state;

    private Gtk.Image icon;
    private Regex? regex;
    private Gtk.Grid grid;

    public ProcessInfoView () {
        //  get_style_context ().add_class ("process_info");
        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
        regex = /(?i:^.*\.(xpm|png)$)/;

        icon = new Gtk.Image.from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
        icon.set_pixel_size (64);
        icon.valign = Gtk.Align.END;

        application_name = new Gtk.Label (_ ("N/A"));
        application_name.get_style_context ().add_class ("h2");
        application_name.ellipsize = Pango.EllipsizeMode.END;
        application_name.tooltip_text = _("N/A");
        application_name.halign = Gtk.Align.START;
        application_name.valign = Gtk.Align.START;


        state = new Gtk.Label (_ ("?"));
        state.halign = Gtk.Align.START;
        state.get_style_context ().add_class (Granite.STYLE_CLASS_BADGE);

        pid = new Gtk.Label (_ ("PID:N/A"));
        pid.halign = Gtk.Align.START;
        pid.get_style_context ().add_class (Granite.STYLE_CLASS_BADGE);

        ppid = new Gtk.Label (_ ("PPID:N/A"));
        ppid.halign = Gtk.Align.START;
        ppid.get_style_context ().add_class (Granite.STYLE_CLASS_BADGE);

        pgrp = new Gtk.Label (_ ("PGRP:N/A"));
        pgrp.halign = Gtk.Align.START;
        pgrp.get_style_context ().add_class (Granite.STYLE_CLASS_BADGE);

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        wrapper.add (state);
        wrapper.add (   pid);
        wrapper.add (  pgrp);
        wrapper.add (  ppid);

        /* ==========START COMMAND WIDGET============== */
        // command widget should be a widget that contains one line, but expands on click
        // when clicked it should reveal full command
        command = new Gtk.TextView ();
        command.buffer.text = "N/A";
        command.pixels_above_lines = 3;
        command.margin = 8;
        command.set_wrap_mode (Gtk.WrapMode.WORD);
        // setting resize mode, so command wraps immediatly when right sidebar changed
        //  command.resize_mode = Gtk.ResizeMode.IMMEDIATE;
        command.get_style_context ().add_class ("command");

        command_wrapper = new Gtk.ScrolledWindow (null, null);
        command_wrapper.get_style_context ().add_class ("command_wrapper");
        command_wrapper.margin_top = 24;
        //  command_wrapper.resize_mode = Gtk.ResizeMode.IMMEDIATE;
        command_wrapper.add (command);
        /* ==========END COMMAND WIDGET============== */


        grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("horizontal");
        grid.column_spacing = 12;


        grid.attach (            icon, 0, 0, 1, 2);
        grid.attach (application_name, 1, 0, 3, 1);
        grid.attach (         wrapper, 1, 1, 1, 1);

        add (           grid);
        add (command_wrapper);
    }

    public void update (Process process) {
        // probably not ok to update everything
        // TODO: find a better way to do this
        if (pid.get_text() != ("PID:%d").printf (process.stat.pid)) {
            command.buffer.text = process.command;
        }
        application_name.set_text (("%s").printf (process.application_name));
        application_name.tooltip_text = process.application_name;
        pid.set_text (("PID:%d").printf (process.stat.pid));
        ppid.set_text (("PPID:%d").printf (process.stat.ppid));
        pgrp.set_text (("PGRP:%d").printf (process.stat.pgrp));
        state.set_text (process.stat.state);

        var icon_name = process.icon.to_string ();

        if (!regex.match (icon_name)) {
            icon.set_from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        } else {
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_size (icon_name, 64, -1);
                icon.set_from_pixbuf (pixbuf);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    public void pid_widget () {
    }
}