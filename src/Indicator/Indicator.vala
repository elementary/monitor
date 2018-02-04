// TODO: Change namespace
public class Monitor.Indicator : Wingpanel.Indicator {

    private Widgets.DisplayWidget? display_widget = null;
    private Widgets.PopoverWidget? popover_widget = null;

    construct {
        /* Indicator should be visible at startup */
        this.visible = true;
        display_widget = new Widgets.DisplayWidget ();
        popover_widget = new Widgets.PopoverWidget ();

        DBusClient.get_default ();
    }

    /* Constructor */
    public Indicator () {
        /* Some information about the indicator */
        Object (code_name : "monitor-indicator", /* Unique name */
                display_name : _("Monitor Indicator"), /* Localised name */
                description: _("Show system resources")); /* Short description */
    }

    /* This method is called to get the widget that is displayed in the top bar */
    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    /* This method is called when the indicator popover opened */
    public override void opened () {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed () {
    }

    /* Method to connect the signals */
    private void connect_signals () {
        /* Connect to the click signal of the hide button */
        // hide_button.clicked.connect (hide_me);

        /* Connect to the switch signal of the compositing switch */
        // compositing_switch.switched.connect (update_compositing);
    }

    /* Method to hide the indicator for a short time */
    // private void hide_me () {
    //     /* Hide the indicator */
    //     this.visible = false;
    //
    //     /* Show the indicator after two seconds */
    //     Timeout.add (2000, () => {
    //         /* Show it */
    //         this.visible = true;
    //
    //         /* Don't run this timer in an endless loop */
    //         return false;
    //     });
    // }

    /* Method to check the status of the compositing switch and update the indicator */
    private void update_compositing () {
        /* If the switch is enabled set the icon name of the icon that should be drawn on top of the other one, if not hide the top icon. */
        // display_widget.set_overlay_icon_name (compositing_switch.get_active () ? "nm-vpn-active-lock" : "");
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
