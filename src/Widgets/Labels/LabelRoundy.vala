public class Monitor.LabelRoundy : Gtk.Fixed {
    public Gtk.Label val;
    public Gtk.Label desc;

    public LabelRoundy (string description) {
        val = new Gtk.Label (Utils.NO_DATA);
        val.get_style_context ().add_class ("roundy-label");

        desc = new Gtk.Label (description.up ());
        desc.get_style_context ().add_class ("small-text");

        put (val, 0, 12);
        put (desc, 6, 0);
    }

    public void set_color (string colorname) {
        val.get_style_context ().add_class (colorname);
    }

    public void set_text (string text) {
        val.set_text (text);
    }

}
