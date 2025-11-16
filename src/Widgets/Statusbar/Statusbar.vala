/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.Statusbar : Granite.Bin {
    private Gtk.Label cpu_usage_label;
    private Gtk.Label memory_usage_label;
    private Gtk.Label swap_usage_label;
    private Gtk.Label gpu_usage_label;

    construct {
        var cpu_icon = new Gtk.Image.from_icon_name ("cpu-symbolic") {
            tooltip_text = _("CPU")
        };

        cpu_usage_label = new Gtk.Label (_("Calculating…")) {
            width_chars = 4,
            xalign = 0
        };

        var ram_icon = new Gtk.Image.from_icon_name ("ram-symbolic") {
            tooltip_text = _("Memory")
        };

        memory_usage_label = new Gtk.Label (_("Calculating…")) {
            margin_start = 6,
            width_chars = 4,
            xalign = 0
        };

        var swap_icon = new Gtk.Image.from_icon_name ("swap-symbolic") {
            tooltip_text = _("Swap")
        };

        swap_usage_label = new Gtk.Label (_("Calculating…")) {
            margin_start = 6,
            width_chars = 4,
            xalign = 0
        };

        var gpu_icon = new Gtk.Image.from_icon_name ("gpu-symbolic") {
            tooltip_text = _("GPU")
        };

        gpu_usage_label = new Gtk.Label (_("Calculating…")) {
            margin_start = 6,
            width_chars = 4,
            xalign = 0
        };

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_start (cpu_icon);
        action_bar.pack_start (cpu_usage_label);
        action_bar.pack_start (ram_icon);
        action_bar.pack_start (memory_usage_label);
        action_bar.pack_start (swap_icon);
        action_bar.pack_start (swap_usage_label);
        action_bar.pack_start (gpu_icon);
        action_bar.pack_start (gpu_usage_label);

        child = action_bar;
    }

    public bool update (ResourcesSerialized sysres) {
        cpu_usage_label.label = ("%d%%").printf (sysres.cpu_percentage);
        memory_usage_label.label = ("%u%%").printf (sysres.memory_percentage);
        gpu_usage_label.label = ("%d%%").printf (sysres.gpu_percentage);

        cpu_usage_label.tooltip_text = ("%.2f %s").printf (sysres.cpu_frequency, _("GHz"));

        memory_usage_label.tooltip_text = ("%s / %s").printf (
            format_size ((uint64) sysres.memory_used, IEC_UNITS),
            format_size ((uint64) sysres.memory_total, IEC_UNITS)
        );

        // The total amount of the swap is 0 when it is unavailable
        if (sysres.swap_total == 0) {
            swap_usage_label.label = _("N/A");
        } else {
            swap_usage_label.label = ("%d%%").printf (sysres.swap_percentage);
            swap_usage_label.tooltip_text = ("%s / %s").printf (
                // We get a value in GB, not bytes
                format_size ((uint64) sysres.swap_used, IEC_UNITS),
                format_size ((uint64) sysres.swap_total, IEC_UNITS)
            );
        }

        return true;
    }

}
