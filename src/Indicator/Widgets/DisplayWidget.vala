public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    private Gtk.Image image;
    private Gtk.Revealer percent_revealer;
    private Gtk.Label percent_label;
    private bool allow_percent = false;

    construct {
        valign = Gtk.Align.CENTER;

        image = new Gtk.Image ();
        image.icon_name = "content-loading-symbolic";
        image.pixel_size = 24;

        percent_label = new Gtk.Label ("yay");
        percent_label.margin = 2;

        // percent_revealer = new Gtk.Revealer ();
        // update_revealer ();
        // percent_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        percent_revealer.add (percent_label);

        // add (image);
        add (percent_label);

        // Services.SettingsManager.get_default ().notify["show-percentage"].connect (update_revealer);
        //
        // button_press_event.connect ((e) => {
        //     if (allow_percent && e.button == Gdk.BUTTON_MIDDLE) {
        //         Services.SettingsManager sm = Services.SettingsManager.get_default ();
        //         sm.show_percentage = !sm.show_percentage;
        //         return true;
        //     }
        //     return false;
        // });
    }

    public void set_icon_name (string icon_name, bool allow_percent) {
        image.icon_name = icon_name;

        if (this.allow_percent != allow_percent) {
            this.allow_percent = allow_percent;
            update_revealer ();
        }
    }

    public void set_percent (int percentage) {
        percent_label.set_label ("%i%%".printf (percentage));
    }

    private void update_revealer () {
        // percent_revealer.reveal_child = Services.SettingsManager.get_default ().show_percentage && allow_percent;
    }
}
