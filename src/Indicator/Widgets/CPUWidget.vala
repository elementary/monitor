public class Monitor.Widgets.CPUWidget : Gtk.Box {
    private Gtk.Label percentage_label;
    private Gtk.Label cpu_indicator_text;
    string cpu_text;
    public int percentage {
        set { percentage_label.set_label ("%i%%".printf (value)); }
    }
    Gtk.Image image;

    construct {
        image = new Gtk.Image ();
        //  image.icon_name = "multimedia-player-symbolic";
        //  image.pixel_size = 16;

        cpu_text = _("cpu");
        cpu_indicator_text = new Gtk.Label (cpu_text);

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 2;

        //  pack_start (image);
        pack_start (cpu_indicator_text);
        pack_start (percentage_label);
    }

    public CPUWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }

}
