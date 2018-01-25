
public class Monitor.Indicator : Wingpanel.Indicator {
    /* Our display widget, a composited icon */
    private Wingpanel.Widgets.OverlayIcon? display_widget = null;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid? main_widget = null;

    /* Button to hide the indicator */
    private Wingpanel.Widgets.Button hide_button;

    /* Switch to set the compositing mode of the icon */
    private Wingpanel.Widgets.Switch compositing_switch;

    /* Constructor */
    public Indicator () {
        /* Some information about the indicator */
        Object (code_name : "monitor-indicator", /* Unique name */
                display_name : _("Sample Indicator"), /* Localised name */
                description: _("Does nothing, but it is cool!")); /* Short description */

        /* Indicator should be visible at startup */
        this.visible = true;
    }

    /* This method is called to get the widget that is displayed in the top bar */
    public override Gtk.Widget get_display_widget () {
        /* Check if the display widget is already created */
        if (display_widget == null) {
            /* Create a new composited icon */
            display_widget = new Wingpanel.Widgets.OverlayIcon ("dialog-information-symbolic");
        }

        /* Return our display widget */
        return display_widget;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget? get_widget () {
        /* Check if the main widget is already created */
        if (main_widget == null) {
            /* Create the main widget */
            main_widget = create_main_widget ();

            /* Connect the signals */
            connect_signals ();
        }

        /* Return our main widget */
        return main_widget;
    }

    /* This method is called when the indicator popover opened */
    public override void opened () {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed () {
        /* Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else... */
    }

    /* Let's move this gui code to an own method to make the code better readable */
    private Gtk.Grid create_main_widget () {
        /* Create the grid for our content */
        var grid = new Gtk.Grid ();

        /* Create the hide button */
        hide_button = new Wingpanel.Widgets.Button (_("Hide me!"));

        /* Create the compositing switch */
        compositing_switch = new Wingpanel.Widgets.Switch (_("Composited Icon"));

        /* Add the widgets */
        grid.attach (hide_button, 0, 0, 1, 1);
        grid.attach (new Wingpanel.Widgets.Separator (), 0, 1, 1, 1);
        grid.attach (compositing_switch, 0, 2, 1, 1);

        /* Return the grid */
        return grid;
    }

    /* Method to connect the signals */
    private void connect_signals () {
        /* Connect to the click signal of the hide button */
        hide_button.clicked.connect (hide_me);

        /* Connect to the switch signal of the compositing switch */
        compositing_switch.switched.connect (update_compositing);
    }

    /* Method to hide the indicator for a short time */
    private void hide_me () {
        /* Hide the indicator */
        this.visible = false;

        /* Show the indicator after two seconds */
        Timeout.add (2000, () => {
            /* Show it */
            this.visible = true;

            /* Don't run this timer in an endless loop */
            return false;
        });
    }

    /* Method to check the status of the compositing switch and update the indicator */
    private void update_compositing () {
        /* If the switch is enabled set the icon name of the icon that should be drawn on top of the other one, if not hide the top icon. */
        display_widget.set_overlay_icon_name (compositing_switch.get_active () ? "nm-vpn-active-lock" : "");
    }
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating Sample Indicator");

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our monitor indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    /* Create the indicator */
    var indicator = new Monitor.Indicator ();

    /* Return the newly created indicator */
    return indicator;
}
