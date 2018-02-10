public class Monitor.Widgets.MemoryWidget : Gtk.Box {
    private Gtk.Label percentage_label;
    public int percentage {
        set { percentage_label.set_label ("%i%%".printf (value)); }
    }
    Gtk.Image image;

    construct {
        image = new Gtk.Image ();
        image.icon_name = "phone-symbolic";
        image.pixel_size = 16;

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 2;

        pack_start (image);
        pack_start (percentage_label);

    }

    public MemoryWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }

}
