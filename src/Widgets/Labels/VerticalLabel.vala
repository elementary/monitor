public class Monitor.VerticalLabel : Gtk.Grid {

    public Gtk.Label val;
    public Gtk.Label desc;

    construct {
        margin_start = 12;
        margin_top = 6;
    }

    public VerticalLabel (string description) {
        val = new Gtk.Label (Utils.NO_DATA);
        //  val.get_style_context ().add_class ("h2");

        val.get_style_context ().add_class ("vertical-label");

        desc = new Gtk.Label (description);
        //  desc.get_style_context ().add_class ("h4");
        desc.get_style_context ().add_class ("small-text");

        attach(desc, 0, 0, 1, 1);
        attach(val, 0, 1, 1, 1);
    }

    public void set_text (string text) {
        val.set_text (text);
    }
}