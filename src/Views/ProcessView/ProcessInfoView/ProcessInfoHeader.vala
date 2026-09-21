/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoHeader : Gtk.Grid {
    private Gtk.Image icon;
    private Gtk.Image state_image;
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

        state_image = new Gtk.Image.from_icon_name ("state-unknown-symbolic") {
            halign = START,
            valign = END
        };

        var icon_container = new Gtk.Overlay () {
            child = icon
        };
        icon_container.add_overlay (state_image);

        application_name = new Gtk.Label (_("N/A")) {
            ellipsize = END,
            halign = START,
            valign = START,
            tooltip_text = _("N/A")
        };
        application_name.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        pid = new LabelRoundy (_("PID"));
        nice = new LabelRoundy (_("NI"));
        priority = new LabelRoundy (_("PRI"));
        num_threads = new LabelRoundy (_("THR"));
        // ppid = new LabelRoundy (_("PPID"));
        // pgrp = new LabelRoundy (_("PGRP"));

        // TODO: tooltip_text UID
        username = new LabelRoundy ("");

        var wrapper = new Gtk.Box (HORIZONTAL, 0);
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
        pid.text = process.stat.pid.to_string ();
        nice.text = process.stat.nice.to_string ();
        priority.text = process.stat.priority.to_string ();

        if (process.uid == 0) {
            username.add_css_class ("username-root");
            username.remove_css_class ("username-other");
        } else if (process.uid == (int) Posix.getuid ()) {
            username.remove_css_class ("username-other");
            username.remove_css_class ("username-root");
        } else {
            username.add_css_class ("username-other");
            username.remove_css_class ("username-root");
        }

        username.text = process.username;
        username.tooltip_text = process.uid.to_string ();

        num_threads.text = process.stat.num_threads.to_string ();

        update_state (process.stat.state);

        icon.gicon = process.icon;
    }

    private void update_state (string state) {
        state_image.css_classes = {Granite.CssClass.CIRCULAR, "state", state};
        switch (state) {
            case "D":
                state_image.icon_name = "media-playback-pause-symbolic";
                state_image.tooltip_text = _("The app is waiting in an uninterruptible disk sleep");
                break;
            case "I":
                state_image.icon_name = "";
                state_image.tooltip_text = _("Idle kernel thread");
                break;
            case "R":
                state_image.icon_name = "media-playback-start-symbolic";
                state_image.tooltip_text = _("The process is running or runnable (on run queue)");
                break;
            case "S":
                state_image.icon_name = "process-sleep";
                state_image.tooltip_text = _("The process is in an interruptible sleep; waiting for an event to complete");
                break;
            case "T":
                state_image.icon_name = "media-playback-stop-symbolic";
                state_image.tooltip_text = _("The process is stopped by a job control signal");
                break;
            case "t":
                state_image.icon_name = "media-playback-stop-symbolic";
                state_image.tooltip_text = _("The process is stopped by a debugger during the tracing");
                break;
            case "Z":
                state_image.icon_name = "process-fail-symbolic";
                state_image.tooltip_text = _("The app is terminated but not reaped by its parent");
                break;
            default:
                state_image.icon_name = "state-unknown-symbolic";
                state_image.tooltip_text = "";
                break;
        }
    }

}
