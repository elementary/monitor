/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoHeader : Gtk.Grid {
    private Gtk.Image icon;
    public Gtk.Label state;
    public Gtk.Label application_name;
    public LabelRoundy pid;

    public LabelRoundy ppid;
    public LabelRoundy pgrp;
    public LabelRoundy nice;
    public LabelRoundy priority;
    public LabelRoundy num_threads;
    public LabelRoundy username;

    private Regex ? regex;

    construct {
        column_spacing = 12;

        /* *INDENT-OFF* */
        regex = /(?i:^.*\.(xpm|png)$)/; // vala-lint=space-before-paren,
        /* *INDENT-ON* */

        icon = new Gtk.Image.from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
        icon.set_pixel_size (64);
        icon.valign = Gtk.Align.END;

        state = new Gtk.Label ("?");
        state.halign = Gtk.Align.START;
        state.get_style_context ().add_class ("state_badge");

        var icon_container = new Gtk.Fixed ();
        icon_container.put (icon, 0, 0);
        icon_container.put (state, -5, 48);

        application_name = new Gtk.Label (_("N/A"));
        application_name.get_style_context ().add_class ("h2");
        application_name.ellipsize = Pango.EllipsizeMode.END;
        application_name.tooltip_text = _("N/A");
        application_name.halign = Gtk.Align.START;
        application_name.valign = Gtk.Align.START;

        pid = new LabelRoundy (_("PID"));
        nice = new LabelRoundy (_("NI"));
        priority = new LabelRoundy (_("PRI"));
        num_threads = new LabelRoundy (_("THR"));
        // ppid = new LabelRoundy (_("PPID"));
        // pgrp = new LabelRoundy (_("PGRP"));

        // TODO: tooltip_text UID
        username = new LabelRoundy ("");

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        wrapper.add (pid);
        wrapper.add (priority);
        wrapper.add (nice);
        wrapper.add (num_threads);
        wrapper.add (username);

        attach (icon_container, 0, 0, 1, 2);
        attach (application_name, 1, 0, 3, 1);
        attach (wrapper, 1, 1, 1, 1);
    }

    public void update (Process process) {
        application_name.set_text (process.application_name);
        application_name.tooltip_text = process.command;
        pid.text = process.stat.pid.to_string ();
        nice.text = process.stat.nice.to_string ();
        priority.text = process.stat.priority.to_string ();

        if (process.uid == 0) {
            username.get_style_context ().add_class ("username-root");
            username.get_style_context ().remove_class ("username-other");
        } else if (process.uid == (int) Posix.getuid ()) {
            username.get_style_context ().remove_class ("username-other");
            username.get_style_context ().remove_class ("username-root");
        } else {
            username.get_style_context ().add_class ("username-other");
            username.get_style_context ().remove_class ("username-root");
        }

        username.text = process.username;
        username.tooltip_text = process.uid.to_string ();
        num_threads.text = process.stat.num_threads.to_string ();
        state.set_text (process.stat.state);
        state.tooltip_text = set_state_tooltip ();
        num_threads.text = process.stat.num_threads.to_string ();
        set_icon (process);
    }

    private void set_icon (Process process) {
        // this construction should be somewhere else
        var icon_name = process.icon.to_string ();

        if (!regex.match (icon_name)) {
            icon.set_from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        } else {
            try {
                var pixbuf = new Gdk.Pixbuf.from_file_at_size (icon_name, 48, -1);
                icon.set_from_pixbuf (pixbuf);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    private string set_state_tooltip () {
        switch (state.label) {
        case "D":
            return _("The app is waiting in an uninterruptible disk sleep");
        case "I":
            return _("Idle kernel thread");
        case "R":
            return _("The process is running or runnable (on run queue)");
        case "S":
            return _("The process is in an interruptible sleep; waiting for an event to complete");
        case "T":
            return _("The process is stopped by a job control signal");
        case "t":
            return _("The process is stopped by a debugger during the tracing");
        case "Z":
            return _("The app is terminated but not reaped by its parent");
        default:
            return "";
        }
    }

}
