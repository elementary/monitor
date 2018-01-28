public class Monitor.Widgets.PopoverWidget : Gtk.Grid {
    /* Button to hide the indicator */
    private Wingpanel.Widgets.Button show_monitor_button;
    private Wingpanel.Widgets.Button quit_monitor_button;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        /* Create the hide button */
        show_monitor_button = new Wingpanel.Widgets.Button (_("Show Monitor"));
        quit_monitor_button = new Wingpanel.Widgets.Button (_("Quit Monitor"));


        /* Add the widgets */
        // grid.attach (hide_button, 0, 0, 1, 1);
        // grid.attach (new Wingpanel.Widgets.Separator (), 0, 1, 1, 1);
        // grid.attach (compositing_switch, 0, 2, 1, 1);

        add (show_monitor_button);
        add (new Wingpanel.Widgets.Separator ());
        add (quit_monitor_button);
    }
}
