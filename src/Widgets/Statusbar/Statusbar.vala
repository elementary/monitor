public class Monitor.Statusbar : Gtk.Box {
    Gtk.Label cpu_usage_label;
    Gtk.Label memory_usage_label;
    Gtk.Label swap_usage_label;

    construct {

        var actionbar = new Gtk.ActionBar () {
            hexpand = true,
        };

        var cpu_icon = new Gtk.Image.from_icon_name ("cpu-symbolic") {
            tooltip_text = _("CPU")
        };

        var ram_icon = new Gtk.Image.from_icon_name ("ram-symbolic") {
            tooltip_text = _("Memory")
        };

        var swap_icon = new Gtk.Image.from_icon_name ("swap-symbolic") {
            tooltip_text = _("Swap")
        };

        cpu_usage_label = build_label ();
        actionbar.pack_start (cpu_icon);
        actionbar.pack_start (cpu_usage_label);

        memory_usage_label = build_label ();
        ram_icon.margin_start = 6;
        actionbar.pack_start (ram_icon);
        actionbar.pack_start (memory_usage_label);

        swap_usage_label = build_label ();
        swap_icon.margin_start = 6;
        actionbar.pack_start (swap_icon);
        actionbar.pack_start (swap_usage_label);

        var support_ua_label = new Gtk.LinkButton.with_label ("http://stand-with-ukraine.pp.ua/", _("🇺🇦"));
        var github_label = new Gtk.LinkButton.with_label ("https://github.com/stsdc/monitor", _("Check on Github"));

        var version_label = new Gtk.Label ("%s".printf (VCS_TAG)) {
            selectable = true
        };
        version_label.get_style_context ().add_class ("dim-label");

        // pack_end (build_separator_middot ());
        actionbar.pack_end (github_label);
        actionbar.pack_end (build_separator_middot ());
        actionbar.pack_end (version_label);
        actionbar.pack_end (build_separator_middot ());
        actionbar.pack_end (support_ua_label);

        append (actionbar);
    }

    private Gtk.Label build_label () {
        return new Gtk.Label (_("Calculating…")) {
            width_chars = 4,
            xalign = 0,
            margin_start = 6,
        };
    }

    private Gtk.Label build_separator_middot () {
        var label = new Gtk.Label ("𐄁") {
            margin_end = 6,
            margin_start = 6,
        };
        label.get_style_context ().add_class ("dim-label");
        return label;
    }

    public bool update (ResourcesSerialized sysres) {
        cpu_usage_label.set_text (("%d%%").printf (sysres.cpu_percentage));
        memory_usage_label.set_text (("%u%%").printf (sysres.memory_percentage));

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
