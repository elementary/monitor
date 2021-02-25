public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    public IndicatorWidget cpu_widget;
    public IndicatorWidget memory_widget;

    public TemperatureWidget temperature_widget;
    public NetworkWidget network_up_widget;
    public NetworkWidget network_down_widget;

    construct {
        valign = Gtk.Align.CENTER;

        cpu_widget = new IndicatorWidget ("cpu-symbolic");

        memory_widget = new IndicatorWidget ("ram-symbolic");

        temperature_widget = new TemperatureWidget ("temperature-sensor-symbolic");

        network_up_widget = new NetworkWidget ("up-arrow-symbolic");
        network_down_widget = new NetworkWidget ("down-arrow-symbolic");

        add (cpu_widget);
        add (memory_widget);
        add (temperature_widget);
        add (network_up_widget);
        add (network_down_widget);
    }
}
