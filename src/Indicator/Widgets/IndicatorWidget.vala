public class Monitor.Widgets.IndicatorWidget : Gtk.Box {
    private Gtk.Label percentage_label;

    public string icon_name { get; construct; }
    public int percentage {
        set { percentage_label.label = "%i%%".printf (value); }
    }

    public IndicatorWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 2;

        pack_start (icon);
        pack_start (percentage_label);
    }
}
