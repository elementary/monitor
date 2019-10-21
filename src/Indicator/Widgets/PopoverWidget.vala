public class Monitor.Widgets.PopoverWidget : Gtk.Grid {
    /* Button to hide the indicator */
    private Gtk.ModelButton show_monitor_button;
    private Gtk.ModelButton quit_monitor_button;

    public signal void quit_monitor ();
    public signal void show_monitor ();

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        show_monitor_button = new Gtk.ModelButton ();
        show_monitor_button.text = _("Show Monitor");
        quit_monitor_button = new Gtk.ModelButton ();
        quit_monitor_button.text = _("Quit Monitor");
        show_monitor_button.clicked.connect (() => show_monitor ());
        quit_monitor_button.clicked.connect (() => quit_monitor ());

        add (show_monitor_button);
        add (new Wingpanel.Widgets.Separator ());
        add (quit_monitor_button);
    }
}
