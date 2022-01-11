public class Monitor.Statusbar : Gtk.ActionBar {
    Gtk.Label cpu_usage_label;
    Gtk.Label memory_usage_label;
    Gtk.Label swap_usage_label;

    construct {
        var cpu_icon = new Gtk.Image.from_icon_name ("cpu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        cpu_icon.tooltip_text = _("CPU");

        var ram_icon = new Gtk.Image.from_icon_name ("ram-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        ram_icon.tooltip_text = _("Memory");

        var swap_icon = new Gtk.Image.from_icon_name ("swap-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        swap_icon.tooltip_text = _("Swap");

        cpu_usage_label = new Gtk.Label (_("Calculating…"));
        cpu_usage_label.set_width_chars (4);
        cpu_usage_label.xalign = 0;
        pack_start (cpu_icon);
        pack_start (cpu_usage_label);

        memory_usage_label = new Gtk.Label (_("Calculating…"));
        memory_usage_label.set_width_chars (4);
        memory_usage_label.xalign = 0;
        ram_icon.margin_start = 6;
        pack_start (ram_icon);
        pack_start (memory_usage_label);

        swap_usage_label = new Gtk.Label (_("Calculating…"));
        swap_usage_label.set_width_chars (4);
        swap_usage_label.xalign = 0;
        swap_icon.margin_start = 6;
        pack_start (swap_icon);
        pack_start (swap_usage_label);

        var github_label = new Gtk.LinkButton.with_label ("https://github.com/stsdc/monitor", _("Check on Github")) {
            margin_end = 6
        };

        var version_label = new Gtk.Label ("𐄁    %s".printf (VCS_TAG)) {
            margin_end = 6,
            selectable = true
        };
        version_label.get_style_context ().add_class ("dim-label");

        pack_end (version_label);
        pack_end (github_label);

    }

    public bool update (ResourcesSerialized sysres) {
        cpu_usage_label.set_text (("%d%%").printf (sysres.cpu_percentage));
        memory_usage_label.set_text (("%d%%").printf (sysres.memory_percentage));

        string cpu_tooltip_text = ("%.2f %s").printf (sysres.cpu_frequency, _("GHz"));
        cpu_usage_label.tooltip_text = cpu_tooltip_text;

        string memory_tooltip_text = ("%s / %s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (sysres.memory_used), Utils.HumanUnitFormatter.double_bytes_to_human (sysres.memory_total));
        memory_usage_label.tooltip_text = memory_tooltip_text;

        // The total amount of the swap is 0 when it is unavailable
        if (sysres.swap_total == 0) {
            swap_usage_label.set_text ("N/A");
        } else {
            swap_usage_label.set_text (("%d%%").printf (sysres.swap_percentage));
            string swap_tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.swap_used, _("GiB"), sysres.swap_total, _("GiB"));
            swap_usage_label.tooltip_text = swap_tooltip_text;
        }

        return true;
    }

}
