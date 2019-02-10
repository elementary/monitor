public class Monitor.Widgets.MemoryWidget : Gtk.Box {
    private Gtk.Label percentage_label;
    private Gtk.Label mem_indicator_text;
    private string mem_text;

    public int percentage {
        set { percentage_label.set_label ("%i%%".printf (value)); }
    }
    construct {
        //  image = new Gtk.Image ();
        //  image.icon_name = "phone-symbolic";
        //  image.pixel_size = 16;

        var icon = new Gtk.Image.from_icon_name ("ram-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        mem_text = _("mem");
        mem_indicator_text = new Gtk.Label (mem_text);

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 2;

        pack_start (icon);
        //  pack_start (mem_indicator_text);
        pack_start (percentage_label);

    }

    public MemoryWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }

}
