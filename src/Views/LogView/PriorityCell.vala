/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.PriorityCell : Granite.Bin {
    private Gtk.Image image;

    construct {
        image = new Gtk.Image ();

        child = image;
    }

    public void bind (SystemdLogEntry entry) {
        switch (entry.priority) {
            case INFO:
                image.icon_name = "process-information-symbolic";
                image.tooltip_text = _("Information");
                image.css_classes = {"accent", "blue"};
                break;
            case DEBUG:
                image.icon_name = "bug-symbolic";
                image.tooltip_text = _("Debug");
                image.css_classes = {"accent", "purple"};
                break;
            case NOTICE:
                image.icon_name = "process-attention-symbolic";
                image.tooltip_text = _("Notice");
                image.css_classes = {"accent", "purple"};
                break;
            case ALERT:
                image.icon_name = "process-attention-symbolic";
                image.tooltip_text = _("Alert");    
                image.css_classes = {"accent", "yellow"};
                break;
            case WARNING:
                image.icon_name = "dialog-warning-symbolic";
                image.tooltip_text = _("Warning");
                break;
            case ERR:
                image.icon_name = "process-error-symbolic";
                image.tooltip_text = _("Error");
                break;
            case CRIT:
            case EMERG:
                image.icon_name = "alarm-symbolic";
                image.tooltip_text = _("Emergency");
                image.css_classes = {"error"};
                break;
        }
    }
}
