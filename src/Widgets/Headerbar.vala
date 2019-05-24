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
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var end_process_button = new Gtk.Button.with_label (_("End Process"));
            end_process_button.valign = Gtk.Align.CENTER;
            end_process_button.halign = Gtk.Align.START;
            end_process_button.margin_end = 10;
            end_process_button.clicked.connect (window.process_view.end_process);
            end_process_button.tooltip_text = (_("Ctrl+E"));
            var end_process_button_context = end_process_button.get_style_context ();
            end_process_button_context.add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            var kill_process_button = new Gtk.Button.with_label (_("Kill Process"));
            kill_process_button.valign = Gtk.Align.CENTER;
            end_process_button.halign = Gtk.Align.END;
            kill_process_button.clicked.connect (window.process_view.kill_process);
            kill_process_button.tooltip_text = (_("Ctrl+K"));
            var kill_process_button_context = kill_process_button.get_style_context ();
            kill_process_button_context.add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

            button_box.add (end_process_button);
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

            var indicator_label = new Gtk.Label (_("Show an indicator:"));
            indicator_label.halign = Gtk.Align.END;

            show_indicator_switch = new Gtk.Switch ();
            show_indicator_switch.state = window.saved_state.indicator_state;

            var background_label = new Gtk.Label (_("Start in background:"));
            background_label.halign = Gtk.Align.END;

            background_switch = new Gtk.Switch ();
            background_switch.state = window.saved_state.background_state;
            set_background_switch_state ();

            preferences_grid.attach (indicator_label, 0, 0, 1, 1);
            preferences_grid.attach (show_indicator_switch, 1, 0, 1, 1);
            preferences_grid.attach (background_label, 0, 1, 1, 1);
            preferences_grid.attach (background_switch, 1, 1, 1, 1);

            preferences_grid.show_all ();

            search = new Search (window.process_view, window.generic_model);
            search.valign = Gtk.Align.CENTER;
            pack_end (search);

            show_indicator_switch.notify["active"].connect (() => {
                window.saved_state.indicator_state = show_indicator_switch.state;
                window.dbusserver.indicator_state (show_indicator_switch.state);
                set_background_switch_state ();
            });
            background_switch.notify["active"].connect (() => {
                window.saved_state.background_state = background_switch.state;
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
