
namespace Monitor {

    public class Statusbar : Gtk.ActionBar {
        Resources res;
        Gtk.Label cpu_usage_label;
        Gtk.Label memory_usage_label;
        public Statusbar () {
            res = new Resources ();

                // Memory status


                //ADD BUTTON
                //  var add_img = new Gtk.Image ();
                //  add_img.set_from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
                //  Gtk.Button add_button = new Gtk.Button ();
                //  add_button.set_image (add_img);
                //  add_button.tooltip_text = "Add Folder";

            set_cpu_usage_label ();
            set_memory_usage_label ();

            Timeout.add_seconds (2, () => {
                cpu_usage_label.set_text (("%s %d%%").printf (_("CPU:"), res.get_cpu_usage()));
                memory_usage_label.set_text (("%s %d%%").printf (_("Memory:"), res.get_memory_usage()));
                string tooltip_text = ("%.1f %s / %.1f %s").printf (res.used_memory, _("GiB"), res.total_memory, _("GiB"));
                memory_usage_label.tooltip_text = tooltip_text;
                return true;
            });
        }

        private void set_memory_usage_label () {
            string memory_text = ("%s %d%%").printf (_("Memory:"), res.get_memory_usage());
            memory_usage_label = new Gtk.Label (memory_text);
            memory_usage_label.margin_start = 12;
            pack_start (memory_usage_label);
        }

        private void set_cpu_usage_label () {
            string cpu_text = ("%s %d%%").printf (_("CPU:"), (int) (res.get_cpu_usage()));
            cpu_usage_label = new Gtk.Label (cpu_text);
            pack_start (cpu_usage_label);
        }
    }
}
