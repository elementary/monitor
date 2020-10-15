public class Monitor.Widgets.TemperatureWidget : Gtk.Box {
    private Gtk.Label degree_label;

    public string icon_name { get; construct; }
    public double degree {
        set { degree_label.label = "%d℃".printf ((int)Math.round (value)); }
    }

    public TemperatureWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name
            );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        degree_label = new Gtk.Label (Utils.NOT_AVAILABLE);
        degree_label.margin = 2;

        pack_start (icon);
        pack_start (degree_label);
    }
}
