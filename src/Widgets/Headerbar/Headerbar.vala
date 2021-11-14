public class Monitor.Headerbar : Hdy.HeaderBar {
    private MainWindow window;
    private Gtk.Switch show_indicator_switch;
    private Gtk.Switch background_switch;
    private Gtk.CheckButton indicator_cpu_check;
    private Gtk.CheckButton indicator_memory_check;
    private Gtk.CheckButton indicator_temperature_check;
    private Gtk.CheckButton indicator_network_up_check;
    private Gtk.CheckButton indicator_network_down_check;

    public Search search;
    public Gtk.Grid preferences_grid;

    construct {
        show_close_button = true;
        has_subtitle = false;
        title = _("Monitor");
    }

    public Headerbar (MainWindow window) {
        this.window = window;

        var preferences_button = new Gtk.MenuButton ();
        preferences_button.has_tooltip = true;
        preferences_button.tooltip_text = (_("Settings"));
        preferences_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
        pack_end (preferences_button);

        preferences_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        var preferences_popover = new Gtk.Popover (null);
        preferences_popover.add (preferences_grid);
        preferences_button.popover = preferences_popover;

        var indicator_label = new Gtk.Label (_("Show an indicator:"));
        indicator_label.halign = Gtk.Align.END;

        show_indicator_switch = new Gtk.Switch ();
        show_indicator_switch.state = MonitorApp.settings.get_boolean ("indicator-state");

        var background_label = new Gtk.Label (_("Start in background:"));
        background_label.halign = Gtk.Align.END;

        background_switch = new Gtk.Switch ();
        background_switch.state = MonitorApp.settings.get_boolean ("background-state");
        set_background_switch_state ();

        var indicator_list_label = new Gtk.Label (_("Items in indicator:"));
        indicator_list_label.halign = Gtk.Align.END;

        var indicator_cpu_label = new Gtk.Label (_("CPU"));
        indicator_cpu_check = new Gtk.CheckButton ();
        indicator_cpu_check.active = MonitorApp.settings.get_boolean ("indicator-cpu-state");

        var indicator_memory_label = new Gtk.Label (_("Memory"));
        indicator_memory_check = new Gtk.CheckButton ();
        indicator_memory_check.active = MonitorApp.settings.get_boolean ("indicator-memory-state");

        var indicator_temperature_label = new Gtk.Label (_("Temperature"));
        indicator_temperature_check = new Gtk.CheckButton ();
        indicator_temperature_check.active = MonitorApp.settings.get_boolean ("indicator-temperature-state");

        var indicator_network_up_label = new Gtk.Label (_("Network up"));
        indicator_network_up_check = new Gtk.CheckButton ();
        indicator_network_up_check.active = MonitorApp.settings.get_boolean ("indicator-network-up-state");

        var indicator_network_down_label = new Gtk.Label (_("Network down"));
        indicator_network_down_check = new Gtk.CheckButton ();
        indicator_network_down_check.active = MonitorApp.settings.get_boolean ("indicator-network-down-state");

        //  preferences_grid.attach (indicator_label, 0, 0, 1, 1);
        //  preferences_grid.attach (show_indicator_switch, 1, 0, 1, 1);
        //  preferences_grid.attach (background_label, 0, 1, 1, 1);
        //  preferences_grid.attach (background_switch, 1, 1, 1, 1);

        // Settings popup needs design.
        // Also not sure about new network indicator.
        // Needs design, disabling this for now

        //  preferences_grid.attach (indicator_list_label, 0, 2, 1, 1);
        //  preferences_grid.attach (indicator_cpu_label, 0, 3, 1, 1);
        //  preferences_grid.attach (indicator_cpu_check, 1, 3, 1, 1);
        //  preferences_grid.attach (indicator_memory_label, 0, 4, 1, 1);
        //  preferences_grid.attach (indicator_memory_check, 1, 4, 1, 1);
        //  preferences_grid.attach (indicator_temperature_label, 0, 5, 1, 1);
        //  preferences_grid.attach (indicator_temperature_check, 1, 5, 1, 1);
        //  preferences_grid.attach (indicator_network_up_label, 0, 6, 1, 1);
        //  preferences_grid.attach (indicator_network_up_check, 1, 6, 1, 1);
        //  preferences_grid.attach (indicator_network_down_label, 0, 7, 1, 1);
        //  preferences_grid.attach (indicator_network_down_check, 1, 7, 1, 1);

        preferences_grid.show_all ();

        search = new Search (window);
        search.valign = Gtk.Align.CENTER;
        pack_start (search);

        //  show_indicator_switch.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-state", show_indicator_switch.state);
        //      window.dbusserver.indicator_state (show_indicator_switch.state);
        //      set_background_switch_state ();
        //      set_indicators_check_sensitive ();
        //  });
        indicator_cpu_check.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_cpu_check.active);
            window.dbusserver.indicator_cpu_state (indicator_cpu_check.active);
        });
        indicator_memory_check.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_memory_check.active);
            window.dbusserver.indicator_memory_state (indicator_memory_check.active);
        });
        indicator_temperature_check.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_temperature_check.active);
            window.dbusserver.indicator_temperature_state (indicator_temperature_check.active);
        });
        indicator_network_up_check.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_network_up_check.active);
            window.dbusserver.indicator_network_up_state (indicator_network_up_check.active);
        });
        indicator_network_down_check.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_network_down_check.active);
            window.dbusserver.indicator_network_down_state (indicator_network_down_check.active);
        });
        background_switch.notify["active"].connect (() => {
            MonitorApp.settings.set_boolean ("background-state", background_switch.state);
            set_background_switch_state ();
        });
    }

    private void set_background_switch_state () {
        background_switch.sensitive = show_indicator_switch.active;

        if (!show_indicator_switch.active) {
            background_switch.state = false;
        }
    }
     private void set_indicators_check_sensitive () {
        bool sensitive = show_indicator_switch.active;

        indicator_cpu_check.sensitive = sensitive;
        indicator_memory_check.sensitive = sensitive;
        indicator_temperature_check.sensitive = sensitive;
        indicator_network_up_check.sensitive = sensitive;
        indicator_network_down_check.sensitive = sensitive;
    }

}
