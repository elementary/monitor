public class Monitor.Widgets.CPUWidget : Gtk.Box {
    private Gtk.Label percent_label;
    public int percent {
        set { percent_label.set_label ("%i%%".printf (value)); }
    }
    Gtk.Image image;

    construct {
        image = new Gtk.Image ();
        image.icon_name = "multimedia-player-symbolic";
        image.pixel_size = 24;

        percent_label = new Gtk.Label ("-");
        percent_label.margin = 2;

        pack_start (image);
        pack_start (percent_label);

    }

    public CPUWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }

}
