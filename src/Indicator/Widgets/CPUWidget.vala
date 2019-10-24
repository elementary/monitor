public class Monitor.Widgets.CPUWidget : Gtk.Box {
    private Gtk.Label percentage_label;

    public int percentage {
        set { percentage_label.label = "%i%%".printf (value); }
    }

    public CPUWidget () {
        Object (orientation: Gtk.Orientation.HORIZONTAL);
    }

    construct {
        var icon = new Gtk.Image.from_icon_name ("cpu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 1;

        pack_start (icon);
        pack_start (percentage_label);
    }
}
