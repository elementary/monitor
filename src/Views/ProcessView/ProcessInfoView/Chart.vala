public class Monitor.Chart : Gtk.Box {
    private LiveChart.Serie serie;
    private LiveChart.SmoothLineArea renderer;
    private LiveChart.Chart chart;
    private LiveChart.Config config;


    construct {
        vexpand = true;
        height_request = 60;

        config = new LiveChart.Config ();
        config.y_axis.unit = "%";
        config.y_axis.tick_interval = 25;
        config.y_axis.fixed_max = 100.0;
        config.y_axis.labels.visible = false;
        config.x_axis.labels.visible = false;

        config.padding = LiveChart.Padding () {
            smart = LiveChart.AutoPadding.NONE,
            top = 0,
            right = 0,
            bottom = 0,
            left = 0
        };

        chart = new LiveChart.Chart (config);
        chart.expand = true;
        chart.legend.visible = false;
        chart.grid.visible = false;
        chart.background.main_color = Gdk.RGBA () {
            red= 1, green= 1, blue= 1, alpha= 1
        };                                                                                  //White background

        renderer = new LiveChart.SmoothLineArea (new LiveChart.Values(30));

        serie = new LiveChart.Serie ("CPU 1 usage", renderer);
        serie.set_main_color ({ 0.35, 0.8, 0.1, 1.0});

        chart.add_serie (serie);

        add (chart);
    }

    public void update (double value) {
        chart.add_value (serie, value);
    }

    public void set_data (Gee.ArrayList<double?> history) {
        var refresh_rate_is_ms = 2000; //your own refresh rate in milliseconds      
        chart.add_unaware_timestamp_collection(serie, history, refresh_rate_is_ms);
    }

    public void clear () {
        serie.clear();
    }
}
