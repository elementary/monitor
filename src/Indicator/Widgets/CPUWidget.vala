public class Monitor.Widgets.CPUWidget : Gtk.Box {
    private Gtk.Label percentage_label;
    private Gtk.Label cpu_indicator_text;
    string cpu_text;
    public int percentage {
        set { percentage_label.set_label ("%i%%".printf (value)); }
    }

    construct {
        var icon = new Gtk.Image.from_icon_name ("cpu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        cpu_text = _("cpu");
        cpu_indicator_text = new Gtk.Label (cpu_text);

        percentage_label = new Gtk.Label ("N/A");
        percentage_label.margin = 1;

        pack_start (icon);
        //  pack_start (cpu_indicator_text);
        pack_start (percentage_label);
    }

    public CPUWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}
