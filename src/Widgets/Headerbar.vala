namespace Monitor {

    public class Headerbar : Gtk.HeaderBar {
        private MainWindow window;

        public Search search;

        construct {
            show_close_button = true;
            header_bar.has_subtitle = false;
            title = _("Monitor");
        }

        public Headerbar (MainWindow window) {
            this.window = window;
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            var kill_process_button = new Gtk.Button.with_label (_("End process"));
            kill_process_button.clicked.connect (window.process_view.kill_process);
            kill_process_button.tooltip_text = (_("Ctrl+E"));

            button_box.add (kill_process_button);
            pack_start (button_box);

            search = new Search (window.process_view, window.generic_model);
            pack_end (search);
        }
    }
}
