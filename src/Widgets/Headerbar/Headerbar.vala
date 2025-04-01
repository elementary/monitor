public class Monitor.Headerbar : Hdy.HeaderBar {
    public MainWindow window { get; construct; }
    public Search search { get; private set; }
    public Gtk.Revealer search_revealer { get; private set; }

    public Headerbar (MainWindow window) {
        Object (window: window);
    }

    construct {
        var sv = new PreferencesView ();
        sv.show_all ();

        var preferences_popover = new Gtk.Popover (null);
        preferences_popover.add (sv);

        var preferences_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR),
            popover = preferences_popover,
            tooltip_text = (_("Settings"))
        };

        pack_end (preferences_button);

        search = new Search (window) {
            valign = Gtk.Align.CENTER
        };

        search_revealer = new Gtk.Revealer () {
            child = search,
            transition_type = SLIDE_LEFT
        };

        show_close_button = true;
        has_subtitle = false;
        title = _("Monitor");
        pack_start (search_revealer);
    }
}
