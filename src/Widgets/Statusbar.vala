 public class Monitor.Statusbar : Gtk.ActionBar {
        Gtk.Label cpu_usage_label;
        Gtk.Label memory_usage_label;

        string cpu_text;
        string memory_text;

        construct {
            cpu_text = _("CPU:");
            memory_text = _("Memory:");
            cpu_usage_label = new Gtk.Label (cpu_text);
            pack_start (cpu_usage_label);

            memory_usage_label = new Gtk.Label (memory_text);
            memory_usage_label.margin_start = 6;
            pack_start (memory_usage_label);
        }

        public Statusbar () { }

        public bool update (Utils.SystemResources sysres) {
            cpu_usage_label.set_text (("%s %d%%").printf (cpu_text, sysres.cpu_percentage));
            memory_usage_label.set_text (("%s %d%%").printf (memory_text, sysres.memory_percentage));
            string tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.memory_used, _("GiB"), sysres.memory_total, _("GiB"));
            memory_usage_label.tooltip_text = tooltip_text;
            return true;
        }
}
