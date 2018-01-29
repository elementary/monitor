public class Monitor.Widgets.PopoverWidget : Gtk.Grid {
    /* Button to hide the indicator */
    private Wingpanel.Widgets.Button show_monitor_button;
    private Wingpanel.Widgets.Button quit_monitor_button;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        show_monitor_button = new Wingpanel.Widgets.Button (_("Show Monitor"));
        quit_monitor_button = new Wingpanel.Widgets.Button (_("Quit Monitor"));

        add (show_monitor_button);
        add (new Wingpanel.Widgets.Separator ());
        add (quit_monitor_button);
    }
}
