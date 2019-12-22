public class Monitor.Statusbar : Gtk.ActionBar {
    Gtk.Label cpu_usage_label;
    Gtk.Label memory_usage_label;
    Gtk.Label swap_usage_label;

    construct {
        var cpu_icon = new Gtk.Image.from_icon_name ("cpu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        cpu_icon.tooltip_text = _ ("CPU");

        var ram_icon = new Gtk.Image.from_icon_name ("ram-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        ram_icon.tooltip_text = _ ("Memory");

        var swap_icon = new Gtk.Image.from_icon_name ("swap-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        swap_icon.tooltip_text = _ ("Swap");

        cpu_usage_label = new Gtk.Label (_("Calculating…"));
        pack_start (cpu_icon);
        pack_start (cpu_usage_label);

        memory_usage_label = new Gtk.Label (_("Calculating…"));
        ram_icon.margin_start = 6;
        pack_start (ram_icon);
        pack_start (memory_usage_label);

        swap_usage_label = new Gtk.Label (_("Calculating…"));
        swap_icon.margin_start = 6;
        pack_start (swap_icon);
        pack_start (swap_usage_label);
    }

    public Statusbar () {
    }

    public bool update (Utils.SystemResources sysres) {
        cpu_usage_label.set_text (("%d%%").printf (sysres.cpu_percentage));
        memory_usage_label.set_text (("%d%%").printf (sysres.memory_percentage));

        string memory_tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.memory_used, _ ("GiB"), sysres.memory_total, _ ("GiB"));
        memory_usage_label.tooltip_text = memory_tooltip_text;

        // The total amount of the swap is 0 when it is unavailable
        if (sysres.swap_total == 0) {
            swap_usage_label.set_text ("N/A");
        } else {
            swap_usage_label.set_text (("%d%%").printf (sysres.swap_percentage));
            string swap_tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.swap_used, _ ("GiB"), sysres.swap_total, _ ("GiB"));
            swap_usage_label.tooltip_text = swap_tooltip_text;
        }

        return true;
    }
}
