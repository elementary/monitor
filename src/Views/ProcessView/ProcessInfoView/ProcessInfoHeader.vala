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

    construct {
        column_spacing = 12;

        icon = new Gtk.Image.from_icon_name ("application-x-executable") {
            pixel_size = 64
        };

        state = new Gtk.Label ("?") {
            halign = START,
            valign = END
        };
        state.get_style_context ().add_class ("state_badge");

        var icon_container = new Gtk.Overlay () {
            child = icon
        };
        icon_container.add_overlay (state);

        application_name = new Gtk.Label (_("N/A")) {
            ellipsize = END,
            halign = START,
            valign = START,
            tooltip_text = _("N/A")
        };
        application_name.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        pid = new LabelRoundy (_("PID"));
        nice = new LabelRoundy (_("NI"));
        priority = new LabelRoundy (_("PRI"));
        num_threads = new LabelRoundy (_("THR"));
        // ppid = new LabelRoundy (_("PPID"));
        // pgrp = new LabelRoundy (_("PGRP"));

        // TODO: tooltip_text UID
        username = new LabelRoundy ("");

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        wrapper.append (pid);
        wrapper.append (priority);
        wrapper.append (nice);
        wrapper.append (num_threads);
        wrapper.append (username);

        attach (icon_container, 0, 0, 1, 2);
        attach (application_name, 1, 0, 3, 1);
        attach (wrapper, 1, 1);
    }

    public void update (Process process) {
        application_name.label = process.application_name;
        application_name.tooltip_text = process.command;
        pid.set_text (process.stat.pid.to_string ());
        nice.set_text (process.stat.nice.to_string ());
        priority.set_text (process.stat.priority.to_string ());

        if (process.uid == 0) {
            username.val.add_css_class ("username-root");
            username.val.remove_css_class ("username-other");
            username.val.remove_css_class ("username-current");
        } else if (process.uid == (int) Posix.getuid ()) {
            username.val.add_css_class ("username-current");
            username.val.remove_css_class ("username-other");
            username.val.remove_css_class ("username-root");
        } else {
            username.val.add_css_class ("username-other");
            username.val.remove_css_class ("username-root");
            username.val.remove_css_class ("username-current");
        }

        username.set_text (process.username);
        username.tooltip_text = process.uid.to_string ();

        num_threads.set_text (process.stat.num_threads.to_string ());

        state.label = process.stat.state;
        state.tooltip_text = set_state_tooltip ();

        icon.gicon = process.icon;
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
