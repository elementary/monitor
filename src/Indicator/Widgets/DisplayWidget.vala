public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    public IndicatorWidget cpu_widget;
    public IndicatorWidget memory_widget;

    public TemperatureWidget temperature_widget;

    construct {
        valign = Gtk.Align.CENTER;

        cpu_widget = new IndicatorWidget ("cpu-symbolic");

        memory_widget = new IndicatorWidget ("ram-symbolic");

        temperature_widget = new TemperatureWidget ("temperature-sensor-symbolic");


        add (cpu_widget);
        add (memory_widget);
        add (temperature_widget);
    }
}
