namespace Monitor {
    public class Shortcuts : Object {

        private MainWindow window;
        public bool handled;

        public Shortcuts (MainWindow window) { this.window = window; }

        public bool handle (Gdk.EventKey e) {
            handled = false;
            char typed = e.str[0];

            if (typed.isalnum () && !window.search.is_focus ) {
                window.search.activate_entry (e.str);
                handled = true;
            }

            if((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                switch (e.keyval) {
                    case Gdk.Key.f:
                        window.search.activate_entry ();
                        handled = true;
                        break;
                    case Gdk.Key.e:
                        window.kill_process ();
                        handled = true;
                        break;
                    case Gdk.Key.comma:
                        handled = true;
                        break;
                    case Gdk.Key.period:
                        handled = true;
                        break;
                    default:
                        break;
                }
            }

            switch (e.keyval) {
                case Gdk.Key.Left:
                    window.process_view.collapse ();
                    handled = true;
                    break;
                case Gdk.Key.Right:
                    window.process_view.expanded ();
                    handled = true;
                    break;
                default:
                    break;
            }

            return handled;
        }
    }
}
