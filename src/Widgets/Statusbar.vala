 public class Monitor.Statusbar : Gtk.ActionBar {
        Gtk.Label cpu_usage_label;
        Gtk.Label memory_usage_label;

        construct {
            cpu_usage_label = new Gtk.Label (_("CPU: N/A"));
            pack_start (cpu_usage_label);

            memory_usage_label = new Gtk.Label (_("Memory: N/A"));
            memory_usage_label.margin_left = 6;
            pack_start (memory_usage_label);
        }

        public Statusbar () { }

        public bool update (Utils.SystemResources sysres) {
            cpu_usage_label.set_text (("%s %d%%").printf (_("CPU:"), sysres.cpu_percentage));
            memory_usage_label.set_text (("%s %d%%").printf (_("Memory:"), sysres.memory_percentage));
            string tooltip_text = ("%.1f %s / %.1f %s").printf (sysres.memory_used, _("GiB"), sysres.memory_total, _("GiB"));
            memory_usage_label.tooltip_text = tooltip_text;
            return true;
        }
}
