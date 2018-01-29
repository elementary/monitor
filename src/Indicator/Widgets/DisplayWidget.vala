public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    private Gtk.Revealer percent_revealer;
    private bool allow_percent = false;

    private CPUWidget cpu_widget;
    private RAMWidget ram_widget;

    construct {
        valign = Gtk.Align.CENTER;

        cpu_widget = new CPUWidget ();
        cpu_widget.percent = 34;
        ram_widget = new RAMWidget ();
        ram_widget.percent = 78;

        // percent_revealer = new Gtk.Revealer ();
        // update_revealer ();
        // percent_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        // percent_revealer.add (percent_label);

        add (cpu_widget);
        add (ram_widget);

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

    // public void set_icon_name (string icon_name, bool allow_percent) {
    //     image.icon_name = icon_name;
    //
    //     if (this.allow_percent != allow_percent) {
    //         this.allow_percent = allow_percent;
    //         update_revealer ();
    //     }
    // }

    // public void set_percent (int percentage) {
    //     percent_label.set_label ("%i%%".printf (percentage));
    // }

    private void update_revealer () {
        // percent_revealer.reveal_child = Services.SettingsManager.get_default ().show_percentage && allow_percent;
    }
}
