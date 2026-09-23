/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoHeader : Granite.Box {
    private Gtk.Image icon;
    private Gtk.Label state;
    private Granite.HeaderLabel application_name;
    private LabelRoundy pid;

    private LabelRoundy nice;
    private LabelRoundy priority;
    private LabelRoundy num_threads;
    private LabelRoundy username;

    public ProcessInfoHeader () {
        Object (
            child_spacing: Granite.Box.Spacing.SINGLE,
            orientation: Gtk.Orientation.HORIZONTAL
        );
    }

    construct {
        icon = new Gtk.Image.from_icon_name ("application-x-executable") {
            pixel_size = 64
        };

        state = new Gtk.Label ("?") {
            halign = START,
            valign = END
        };
        state.add_css_class ("pill");
        state.add_css_class ("state");

        var icon_container = new Gtk.Overlay () {
            child = icon
        };
        icon_container.add_overlay (state);

        application_name = new Granite.HeaderLabel (_("N/A")) {
            size = H2,
            ellipsize = END
        };

        pid = new LabelRoundy (_("PID"));
        nice = new LabelRoundy (_("NI"));
        priority = new LabelRoundy (_("PRI"));
        num_threads = new LabelRoundy (_("THR"));

        username = new LabelRoundy ("");

        var wrapper = new Gtk.Box (HORIZONTAL, 0);
        wrapper.append (pid);
        wrapper.append (priority);
        wrapper.append (nice);
        wrapper.append (num_threads);
        wrapper.append (username);

        var label_box = new Granite.Box (VERTICAL);
        label_box.append (application_name);
        label_box.append (wrapper);

        append (icon_container);
        append (label_box);
    }

    public void update (Process process) {
        application_name.label = process.application_name;
        application_name.secondary_text = process.command;
        pid.text = process.stat.pid.to_string ();
        nice.text = process.stat.nice.to_string ();
        priority.text = process.stat.priority.to_string ();

        if (process.uid == 0) {
            username.css_classes = {"username-root"};
        } else if (process.uid == (int) Posix.getuid ()) {
            username.css_classes = {""};
        } else {
            username.css_classes = {"username-other"};
        }

        username.text = process.username;
        username.tooltip_text = process.uid.to_string ();

        num_threads.text = process.stat.num_threads.to_string ();

        state.label = process.stat.state;
        state.tooltip_text = set_state_tooltip (process.stat.state);

        icon.gicon = process.icon;
    }

    private string set_state_tooltip (string state) {
        switch (state) {
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
