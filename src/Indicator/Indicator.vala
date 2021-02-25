// TODO: Change namespace
public class Monitor.Indicator : Wingpanel.Indicator {
    private Widgets.DisplayWidget ? display_widget = null;
    private Widgets.PopoverWidget ? popover_widget = null;
    private Settings settings;
    private DBusClient dbusclient;

    construct {
        Gtk.IconTheme.get_default ().add_resource_path ("/com/github/stsdc/monitor/icons");
        settings = new Settings ("com.github.stsdc.monitor.settings");
        this.visible = false;
        display_widget = new Widgets.DisplayWidget ();
        popover_widget = new Widgets.PopoverWidget ();

        dbusclient = DBusClient.get_default ();

        dbusclient.monitor_vanished.connect (() => this.visible = false);
        dbusclient.monitor_appeared.connect (() => this.visible = settings.get_boolean ("indicator-state"));

        dbusclient.interface.indicator_state.connect ((state) => this.visible = state);

        dbusclient.interface.update.connect ((sysres) => {
            display_widget.cpu_widget.percentage = sysres.cpu_percentage;
            display_widget.temperature_widget.degree = sysres.cpu_temperature;
            display_widget.memory_widget.percentage = sysres.memory_percentage;
            display_widget.network_up_widget.bandwith = sysres.network_up;
            display_widget.network_down_widget.bandwith = sysres.network_down;
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

    public Indicator () {
        Object (code_name: "monitor");
    }

    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    public override Gtk.Widget ? get_widget () {
        return popover_widget;
    }

    public override void opened () {
    }

    public override void closed () {
    }

}

public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating Monitor Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our monitor indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    var indicator = new Monitor.Indicator ();
    return indicator;
}
