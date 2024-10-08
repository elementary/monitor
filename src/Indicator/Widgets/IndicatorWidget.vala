public class Monitor.IndicatorWidget : Gtk.Box {

    public string icon_name { get; construct; }

    public uint state_percentage {
        set {
            label.label = "%u%%".printf (value);
            label.get_style_context ().remove_class ("monitor-indicator-label-warning");
            label.get_style_context ().remove_class ("monitor-indicator-label-critical");

            if (value > 80) {
                label.get_style_context ().add_class ("monitor-indicator-label-warning");
            }
            if (value > 90) {
                label.get_style_context ().add_class ("monitor-indicator-label-critical");
            }
        }
    }

    public int state_temperature {
        set {
            label.label = "%i℃".printf (value);
        }
    }

    public double state_frequency {
        set {
            label.label = ("%.2f %s").printf (value, _("GHz"));
        }
    }

    public int state_bandwidth {
        set {
            label.label = ("%s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (value.to_string (), true));
        }
    }

    private Gtk.Label label = new Gtk.Label (Utils.NOT_AVAILABLE);

    public IndicatorWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name,
            visible: false
            );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);
        label.margin = 2;
        label.width_chars = 4;
        pack_start (icon);
        pack_start (label);
    }
}
