class LabelH4 : Gtk.Label {

    construct {
        get_style_context ().add_class ("h4");
        valign = Gtk.Align.START;
        halign = Gtk.Align.START;
        margin_start = 6;
        ellipsize = Pango.EllipsizeMode.END;
    }

    public LabelH4 (string label) {
        Object (label: label);
    }
}