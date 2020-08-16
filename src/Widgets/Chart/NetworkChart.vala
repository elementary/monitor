public class Monitor.NetworkChart : Gtk.Box {
    private LiveChart.Chart live_chart;
    public LiveChart.Config config;

    construct {
        get_style_context ().add_class ("graph");

        vexpand = true;
        height_request = 120;

        config = new LiveChart.Config ();
        //  config.y_axis.unit = "%";
        //  config.y_axis.tick_interval = 25;
        //  config.y_axis.fixed_max = 100.0;
        config.y_axis.labels.visible = false;
        config.x_axis.labels.visible = false;

        config.padding = LiveChart.Padding () {
            smart = LiveChart.AutoPadding.NONE,
            top = 0,
            right = 0,
            bottom = 0,
            left = -1
        };

        live_chart = new LiveChart.Chart (config);
        live_chart.expand = true;
        live_chart.legend.visible = false;
        live_chart.grid.visible = true;
        live_chart.background.main_color = Gdk.RGBA () {
            red= 1, green= 1, blue= 1, alpha= 1
        };                                                                                  //White background

    }

    public NetworkChart (int series_quantity) {
        for (int i = 0; i < series_quantity; i++) {
            var renderer = new LiveChart.SmoothLineArea (new LiveChart.Values(1000));
            var serie = new LiveChart.Serie (("Serie %d").printf(i), renderer);
            serie.set_main_color ({ 0.35 + i/20, 0.8, 0.1, 1.0});
            live_chart.add_serie (serie);

            // workaround for `gee_collection_get_size: assertion 'self != NULL' failed`
            // https://github.com/lcallarec/live-chart/issues/16
            live_chart.add_value (serie, 3.0);
        }
        add (live_chart);
    }

    public void update (int serie_number, double value) {
        live_chart.add_value_by_index (serie_number, value);
    }

    //  public void set_data (int serie_number, Gee.ArrayList<double?> history) {
    //      var refresh_rate_is_ms = 2000; //your own refresh rate in milliseconds      
    //      live_chart.add_unaware_timestamp_collection(live_chart.series[serie_number], history, refresh_rate_is_ms);
    //  }


    public void clear () {
        //  var series = live_chart.series;
        //  foreach (var serie in series) {
        //      serie.clear();
        //  }
    }
}
