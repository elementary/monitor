public class Monitor.RoundyLabel : Gtk.Fixed {

    public Gtk.Label val;
    public Gtk.Label desc;

    public RoundyLabel (string description) {
        val = new Gtk.Label (Utils.NO_DATA);
        val.get_style_context ().add_class ("roundy-label");

        desc = new Gtk.Label (description);
        desc.get_style_context ().add_class ("small-text");

        put(val, 0, 12);
        put(desc, 6, 0);
    }

    public void set_text (string text) {
        val.set_text (text);
    }
}