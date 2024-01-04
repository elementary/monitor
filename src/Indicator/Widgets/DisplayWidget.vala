public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    public IndicatorWidget cpu_widget = new IndicatorWidget ("cpu-symbolic");
    public IndicatorWidget memory_widget = new IndicatorWidget ("ram-symbolic");

    public IndicatorWidget temperature_widget = new IndicatorWidget ("temperature-sensor-symbolic");
    public IndicatorWidget network_up_widget = new IndicatorWidget ("go-up-symbolic");
    public IndicatorWidget network_down_widget = new IndicatorWidget ("go-down-symbolic");

    public IndicatorWidget gpu_widget = new IndicatorWidget ("gpu-symbolic");
    public IndicatorWidget gpu_temperature_widget = new IndicatorWidget ("temperature-gpu-symbolic");

    construct {
        valign = Gtk.Align.CENTER;

        add (cpu_widget);
        add (memory_widget);
        add (gpu_widget);
        add (gpu_temperature_widget);
        add (temperature_widget);
        add (network_up_widget);
        add (network_down_widget);
    }
}
