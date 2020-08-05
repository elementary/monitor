public class Monitor.LabelVertical : Gtk.EventBox {

    private Gtk.Grid grid;

    public signal void clicked ();

    public Gtk.Label val;
    public Gtk.Label desc;

    construct {
        grid = new Gtk.Grid ();
        grid.margin_start = 12;
        grid.margin_top = 6;

        get_style_context ().add_class (Gtk.STYLE_CLASS_CURSOR_HANDLE);
    }

    public LabelVertical (string description) {
        val = new Gtk.Label (Utils.NO_DATA);

        val.get_style_context ().add_class ("vertical-label");

        desc = new Gtk.Label (description);
        desc.get_style_context ().add_class ("small-text");

        grid.attach(desc, 0, 0, 1, 1);
        grid.attach(val, 0, 1, 1, 1);

        add (grid);

        events |= Gdk.EventMask.BUTTON_RELEASE_MASK;

        button_release_event.connect ((event) => {
            clicked ();
            return false;
        });

    }

    public void set_text (string text) {
        val.set_text (text);
    }
}