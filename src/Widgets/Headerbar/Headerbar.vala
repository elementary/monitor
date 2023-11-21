public class Monitor.Headerbar : Gtk.Box {

    public Search search;
    public Gtk.Grid preferences_grid;

    public Gtk.Revealer search_revealer = new Gtk.Revealer () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
    };

    construct {
        //  show_title_buttons = true;
        //  has_subtitle = false;
        //  title_widget = new Gtk.Label(_("Monitor"));
    }

    public Headerbar (Gtk.Widget widget) {

        var headerbar = new Gtk.HeaderBar () {
            hexpand = true,
        };
        headerbar.set_title_widget (widget);

        var preferences_button = new Gtk.MenuButton ();
        preferences_button.has_tooltip = true;
        preferences_button.tooltip_text = (_("Settings"));
        preferences_button.set_icon_name ("open-menu");
        headerbar.pack_end (preferences_button);

        preferences_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        var preferences_popover = new Gtk.Popover ();
        preferences_popover.set_child (preferences_grid);
        preferences_button.popover = preferences_popover;

        //  preferences_grid.show_all ();

        search = new Search () {
            valign = Gtk.Align.CENTER
        };

        search_revealer.set_child (search);

        headerbar.pack_start (search_revealer);
        append (headerbar);
    }

    public void set_title_widget (Gtk.Widget widget) {

    }
}
