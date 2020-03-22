namespace Monitor {

    public class Headerbar : Gtk.HeaderBar {
        private MainWindow window;
        private Gtk.Switch show_indicator_switch;
        private Gtk.Switch background_switch;

        public Search search;

        construct {
            show_close_button = true;
            has_subtitle = false;
            title = _("Monitor");
        }

        public Headerbar (MainWindow window) {
            this.window = window;

            var preferences_button = new Gtk.MenuButton ();
            preferences_button.has_tooltip = true;
            preferences_button.tooltip_text = (_("Settings"));
            preferences_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
            pack_end (preferences_button);

            var preferences_grid = new Gtk.Grid ();
            preferences_grid.margin = 6;
            preferences_grid.row_spacing = 6;
            preferences_grid.column_spacing = 12;
            preferences_grid.orientation = Gtk.Orientation.VERTICAL;

            var preferences_popover = new Gtk.Popover (null);
            preferences_popover.add (preferences_grid);
            preferences_button.popover = preferences_popover;

            var indicator_label = new Gtk.Label (_("Show an indicator:"));
            indicator_label.halign = Gtk.Align.END;

            show_indicator_switch = new Gtk.Switch ();
            show_indicator_switch.state = MonitorApp.settings.get_boolean ("indicator-state");

            var background_label = new Gtk.Label (_("Start in background:"));
            background_label.halign = Gtk.Align.END;

            background_switch = new Gtk.Switch ();
            background_switch.state = MonitorApp.settings.get_boolean ("background-state");
            set_background_switch_state ();

            preferences_grid.attach (indicator_label, 0, 0, 1, 1);
            preferences_grid.attach (show_indicator_switch, 1, 0, 1, 1);
            preferences_grid.attach (background_label, 0, 1, 1, 1);
            preferences_grid.attach (background_switch, 1, 1, 1, 1);

            preferences_grid.show_all ();

            search = new Search (window);
            search.valign = Gtk.Align.CENTER;
            pack_start (search);

            show_indicator_switch.notify["active"].connect (() => {
                MonitorApp.settings.set_boolean ("indicator-state", show_indicator_switch.state);
                window.dbusserver.indicator_state (show_indicator_switch.state);
                set_background_switch_state ();
            });
            background_switch.notify["active"].connect (() => {
                MonitorApp.settings.set_boolean ("background-state", background_switch.state);
                set_background_switch_state ();
            });
        }

        private void set_background_switch_state () {
            background_switch.sensitive = show_indicator_switch.active;

            if (!show_indicator_switch.active) {
                background_switch.state = false;
            }
        }
    }
}
