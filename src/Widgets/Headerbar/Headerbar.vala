public class Monitor.Headerbar : Hdy.HeaderBar {
    private MainWindow window;
    //  private Gtk.Switch show_indicator_switch;
    //  private Gtk.CheckButton indicator_cpu_check;
    //  private Gtk.CheckButton indicator_memory_check;
    //  private Gtk.CheckButton indicator_temperature_check;
    //  private Gtk.CheckButton indicator_network_up_check;
    //  private Gtk.CheckButton indicator_network_down_check;

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


        //  var indicator_network_up_label = new Gtk.Label (_("Network up"));
        //  indicator_network_up_check = new Gtk.CheckButton ();
        //  indicator_network_up_check.active = MonitorApp.settings.get_boolean ("indicator-network-up-state");

        //  var indicator_network_down_label = new Gtk.Label (_("Network down"));
        //  indicator_network_down_check = new Gtk.CheckButton ();
        //  indicator_network_down_check.active = MonitorApp.settings.get_boolean ("indicator-network-down-state");



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
        //  indicator_cpu_check.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_cpu_check.active);
        //      window.dbusserver.indicator_cpu_state (indicator_cpu_check.active);
        //  });
        //  indicator_memory_check.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_memory_check.active);
        //      window.dbusserver.indicator_memory_state (indicator_memory_check.active);
        //  });
        //  indicator_temperature_check.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_temperature_check.active);
        //      window.dbusserver.indicator_temperature_state (indicator_temperature_check.active);
        //  });
        //  indicator_network_up_check.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_network_up_check.active);
        //      window.dbusserver.indicator_network_up_state (indicator_network_up_check.active);
        //  });
        //  indicator_network_down_check.notify["active"].connect (() => {
        //      MonitorApp.settings.set_boolean ("indicator-cpu-state", indicator_network_down_check.active);
        //      window.dbusserver.indicator_network_down_state (indicator_network_down_check.active);
        //  });

    }


}
