public class Monitor.Widgets.NetworkWidget : Gtk.Box {
    private Gtk.Label bandwith_label;

    public string icon_name { get; construct; }
    public int bandwith {
        set {
            bandwith_label.label = ("%s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (value.to_string (), true));
        }
    }

    public NetworkWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name
            );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        bandwith_label = new Gtk.Label (Utils.NOT_AVAILABLE);
        bandwith_label.margin = 2;
        bandwith_label.width_chars = 4;

        pack_start (icon);
        pack_start (bandwith_label);
    }
}
