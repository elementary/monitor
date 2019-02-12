public class Monitor.Statusbar : Gtk.ActionBar {
    Gtk.Label cpu_usage_label;
    Gtk.Label memory_usage_label;

    construct {
        var cpu_icon = new Gtk.Image.from_icon_name ("cpu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        cpu_icon.tooltip_text = _ ("CPU");
        var ram_icon = new Gtk.Image.from_icon_name ("ram-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        ram_icon.tooltip_text = _ ("Memory");

        cpu_usage_label = new Gtk.Label (cpu_text);
        pack_start (cpu_icon);
        pack_start (cpu_usage_label);

        memory_usage_label = new Gtk.Label (memory_text);
        ram_icon.margin_start = 6;
        pack_start (ram_icon);
        pack_start (memory_usage_label);
    }

    public Statusbar () {
    }

    public bool update (Utils.SystemResources sysres) {
        cpu_usage_label.set_text (("%d%%").printf (sysres.cpu_percentage));
        memory_usage_label.set_text (("%d%%").printf (sysres.memory_percentage));
        string tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.memory_used, _ ("GiB"), sysres.memory_total, _ ("GiB"));
        memory_usage_label.tooltip_text = tooltip_text;
        return true;
    }
}
