namespace Monitor {

    public class Headerbar : Gtk.HeaderBar {
        private MainWindow window;

        public Search search;

        construct {
            show_close_button = true;
            has_subtitle = false;
            title = _("Monitor");
        }

        public Headerbar (MainWindow window) {
            this.window = window;
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var kill_process_button = new Gtk.Button.with_label (_("End process"));
            kill_process_button.valign = Gtk.Align.CENTER;
            kill_process_button.clicked.connect (window.process_view.kill_process);
            kill_process_button.tooltip_text = (_("Ctrl+E"));

            button_box.add (kill_process_button);
            pack_start (button_box);

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

            var show_indicator_switch = new Gtk.Switch ();
            show_indicator_switch.state = window.saved_state.indicator_state;

            var switch_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            switch_box.pack_start (new Gtk.Label (_("Show an indicator")), false, false, 0);
            switch_box.pack_start (show_indicator_switch, false, false, 0);

            preferences_grid.add (switch_box);
            preferences_grid.show_all ();

            search = new Search (window.process_view, window.generic_model);
            search.valign = Gtk.Align.CENTER;
            pack_end (search);

            show_indicator_switch.notify["active"].connect (() => {
                window.saved_state.indicator_state = show_indicator_switch.state;
                window.dbusserver.indicator_state (show_indicator_switch.state);
            });
        }
    }
}
