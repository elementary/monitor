
namespace elementarySystemMonitor {

    public class Statusbar : Gtk.ActionBar {
        public Statusbar () {

                // Memory status
                Gtk.Label memory_usage = new Gtk.Label ("Memory: 53%");
                Gtk.Label cpu_usage = new Gtk.Label ("CPU: 53%");
                
                //ADD BUTTON
                //  var add_img = new Gtk.Image ();
                //  add_img.set_from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
                //  Gtk.Button add_button = new Gtk.Button ();
                //  add_button.set_image (add_img);
                //  add_button.tooltip_text = "Add Folder";


                this.pack_start (memory_usage);
                this.pack_start (cpu_usage);

        }
    }
}