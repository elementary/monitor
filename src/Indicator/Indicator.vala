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

        try {
            apply_custom_styles ();
        } catch (GLib.Error e) {
            error ("Failed to load Monitor Indicator CSS styles: %s", e.message);
        }

        dbusclient = DBusClient.get_default ();

        dbusclient.monitor_vanished.connect (() => this.visible = false);
        dbusclient.monitor_appeared.connect (() => {
            this.visible = settings.get_boolean ("indicator-state");
            display_widget.cpu_widget.visible = settings.get_boolean ("indicator-cpu-state");
            display_widget.memory_widget.visible = settings.get_boolean ("indicator-memory-state");
            display_widget.temperature_widget.visible = settings.get_boolean ("indicator-temperature-state");
            display_widget.network_up_widget.visible = settings.get_boolean ("indicator-network-upload-state");
            display_widget.network_down_widget.visible = settings.get_boolean ("indicator-network-download-state");
            display_widget.gpu_widget.visible = settings.get_boolean ("indicator-gpu-state");

        });

        dbusclient.interface.indicator_state.connect ((state) => this.visible = state);
        dbusclient.interface.indicator_cpu_state.connect ((state) => display_widget.cpu_widget.visible = state);
        dbusclient.interface.indicator_memory_state.connect ((state) => display_widget.memory_widget.visible = state);
        dbusclient.interface.indicator_temperature_state.connect ((state) => display_widget.temperature_widget.visible = state);
        dbusclient.interface.indicator_network_up_state.connect ((state) => display_widget.network_up_widget.visible = state);
        dbusclient.interface.indicator_network_down_state.connect ((state) => display_widget.network_down_widget.visible = state);
        dbusclient.interface.indicator_gpu_state.connect ((state) => display_widget.gpu_widget.visible = state);

        dbusclient.interface.update.connect ((sysres) => {
            display_widget.cpu_widget.state_percentage = sysres.cpu_percentage;
            display_widget.temperature_widget.state_temperature = (int) Math.round (sysres.cpu_temperature);
            display_widget.memory_widget.state_percentage = sysres.memory_percentage;
            display_widget.network_up_widget.state_bandwith = sysres.network_up;
            display_widget.network_down_widget.state_bandwith = sysres.network_down;
            display_widget.gpu_widget.state_percentage = sysres.gpu_percentage;
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
        Object (code_name: "Monitor Indicator");
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

    public void apply_custom_styles () throws GLib.Error {
        var provider = new Gtk.CssProvider ();
        string css = """
        .composited-indicator > revealer label.monitor-indicator-label-warning {
            color: @warning_color;
        }
        .composited-indicator > revealer label.monitor-indicator-label-critical {
            color: @error_color;
        }
        """;
        provider.load_from_data (css, -1);

        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
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
