public class Monitor.Widgets.RAMWidget : Gtk.Box {
    private Gtk.Label percent_label;
    public int percent {
        set { percent_label.set_label ("%i%%".printf (value)); }
    }
    Gtk.Image image;

    construct {
        image = new Gtk.Image ();
        image.icon_name = "phone-symbolic";
        image.pixel_size = 24;

        percent_label = new Gtk.Label ("N/A");
        percent_label.margin = 2;

        pack_start (image);
        pack_start (percent_label);

    }

    public RAMWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }

}
