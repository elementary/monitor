// TODO: Change namespace
public class Monitor.Indicator : Wingpanel.Indicator {

    private Widgets.DisplayWidget? display_widget = null;
    private Widgets.PopoverWidget? popover_widget = null;
    private Settings settings;
    private DBusClient dbusclient;

    construct {
        Gtk.IconTheme.get_default().add_resource_path("/com/github/stsdc/monitor/icons");
        settings = new Settings ("com.github.stsdc.monitor.settings");
        this.visible = false;
        display_widget = new Widgets.DisplayWidget ();
        popover_widget = new Widgets.PopoverWidget ();

        dbusclient = DBusClient.get_default ();

        dbusclient.monitor_vanished.connect (() => this.visible = false);
        dbusclient.monitor_appeared.connect (() => this.visible = settings.get_boolean ("indicator-state"));

        dbusclient.interface.indicator_state.connect((state) => this.visible = state);

        dbusclient.interface.update.connect((sysres) => {
            display_widget.cpu_widget.percentage = sysres.cpu_percentage;
            display_widget.memory_widget.percentage = sysres.memory_percentage;
        });

        popover_widget.quit_monitor.connect (() => {
            try {
                dbusclient.interface.quit_monitor ();
                this.visible = false;
            } catch (Error e) {
                warning (e.message);
            }
        });

        popover_widget.show_monitor.connect (() => {
            try {
                close ();
                dbusclient.interface.show_monitor ();
            } catch (Error e) {
                warning (e.message);
            }
        });

    }

    /* Constructor */
    public Indicator () {
        /* Some information about the indicator */
        Object (code_name : "monitor", /* Unique name */
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
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating Monitor Indicator");

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
