namespace Monitor {

    public class Statusbar : Gtk.ActionBar {
        private CPU cpu;
        private Memory memory;

        Gtk.Label cpu_usage_label;
        Gtk.Label memory_usage_label;

        construct {
            memory = new Memory ();
            cpu = new CPU ();

            set_cpu_usage_label ();
            set_memory_usage_label ();

            Timeout.add_seconds (2, update);
        }

        public Statusbar () { }

        public bool update () {
            cpu_usage_label.set_text (("%s %d%%").printf (_("CPU:"), cpu.percentage));
            memory_usage_label.set_text (("%s %d%%").printf (_("Memory:"), memory.percentage));
            string tooltip_text = ("%.1f %s / %.1f %s").printf (memory.used, _("GiB"), memory.total, _("GiB"));
            memory_usage_label.tooltip_text = tooltip_text;
            return true;
        }

        private void set_memory_usage_label () {
            string memory_text = ("%s %d%%").printf (_("Memory:"), memory.percentage);
            memory_usage_label = new Gtk.Label (memory_text);
            memory_usage_label.margin_left = 12;
            pack_start (memory_usage_label);
        }

        private void set_cpu_usage_label () {
            string cpu_text = ("%s %d%%").printf (_("CPU:"), (int) (cpu.percentage));
            cpu_usage_label = new Gtk.Label (cpu_text);
            pack_start (cpu_usage_label);
        }
    }
}
