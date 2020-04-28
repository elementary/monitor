public class Monitor.ProcessInfoHeader : Gtk.Grid {
    private Gtk.Image icon;
    public Gtk.Label state;
    public Gtk.Label application_name;
    public RoundyLabel pid;
    public RoundyLabel ppid;
    public RoundyLabel pgrp;
    public RoundyLabel nice;
    public RoundyLabel priority;
    public RoundyLabel num_threads;
    public RoundyLabel username;

    private Regex ? regex;

    construct {
        column_spacing = 12;

        regex = /(?i:^.*\.(xpm|png)$)/;

        icon = new Gtk.Image.from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
        icon.set_pixel_size (64);
        icon.valign = Gtk.Align.END;

        state = new Gtk.Label ("?");
        state.halign = Gtk.Align.START;
        state.get_style_context ().add_class ("state_badge");

        var icon_container = new Gtk.Fixed ();
        icon_container.put (icon,   0,  0);
        icon_container.put (state, -5, 48);

        application_name = new Gtk.Label (_ ("N/A"));
        application_name.get_style_context ().add_class ("h2");
        application_name.ellipsize = Pango.EllipsizeMode.END;
        application_name.tooltip_text = _ ("N/A");
        application_name.halign = Gtk.Align.START;
        application_name.valign = Gtk.Align.START;

        pid = new RoundyLabel (_ ("PID"));
        nice = new RoundyLabel (_ ("NI"));
        priority = new RoundyLabel (_ ("PRI"));
        num_threads = new RoundyLabel (_ ("THR"));
        //  ppid = new RoundyLabel (_("PPID"));
        //  pgrp = new RoundyLabel (_("PGRP"));

        //  TODO: tooltip_text UID
        username = new RoundyLabel ("");

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        wrapper.add (pid);
        wrapper.add (priority);
        wrapper.add (nice);
        wrapper.add (num_threads);
        wrapper.add (username);

        attach (icon_container,   0, 0, 1, 2);
        attach (application_name, 1, 0, 3, 1);
        attach (wrapper,          1, 1, 1, 1);

    }

    public void update (Process process) {
        application_name.set_text (process.application_name);
        application_name.tooltip_text = process.command;
        pid.set_text (process.stat.pid.to_string());
        nice.set_text (process.stat.nice.to_string());
        priority.set_text (process.stat.priority.to_string());

        if (process.uid == 0) {
            username.val.get_style_context ().add_class ("username-root");
            username.val.get_style_context ().remove_class ("username-other");
            username.val.get_style_context ().remove_class ("username-current");


        } else if (process.uid == (int)Posix.getuid ()) {
            username.val.get_style_context ().add_class ("username-current");
            username.val.get_style_context ().remove_class ("username-other");
            username.val.get_style_context ().remove_class ("username-root");
        } else {
            username.val.get_style_context ().add_class ("username-other");
            username.val.get_style_context ().remove_class ("username-root");
            username.val.get_style_context ().remove_class ("username-current");
        }

        username.set_text (process.username);
        num_threads.set_text (process.stat.num_threads.to_string());
        state.set_text (process.stat.state);
        num_threads.set_text (process.stat.num_threads.to_string());
        set_icon (process);
    }

    private void set_icon (Process process) {
        // this construction should be somewhere else
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
}