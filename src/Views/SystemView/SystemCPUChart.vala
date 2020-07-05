public class Monitor.SystemCPUChart : Gtk.Box {
    private LiveChart.Chart chart;
    private LiveChart.Config config;

    private Gee.ArrayList<LiveChart.Serie?> serie_list;


    construct {
        serie_list = new  Gee.ArrayList<LiveChart.Serie> ();



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
        chart.grid.visible = true;
        chart.background.main_color = Gdk.RGBA () {
            red= 0, green= 0, blue= 0, alpha= 1
        };                                                                                  //White background

        
    }

    public SystemCPUChart (int cores_quantity) {
        for (int i = 0; i < cores_quantity; i++) {
            var renderer = new LiveChart.SmoothLineArea (new LiveChart.Values(1000));
            var serie = new LiveChart.Serie ("Core x", renderer);
            serie.set_main_color ({ 0.35 + i/20, 0.8, 0.1, 1.0});
            chart.add_serie (serie);
            serie_list.add (serie);
        }

        add (chart);
    }

    public void update (int serie_number, double value) {
        chart.add_value (serie_list.get(serie_number), value);
    }

    //  public void set_data (Gee.ArrayList<double?> history) {
    //      var refresh_rate_is_ms = 2000; //your own refresh rate in milliseconds      
    //      chart.add_unaware_timestamp_collection(serie_list[0], history, refresh_rate_is_ms);
    //  }

    public void clear () {
        //  var series = chart.series;
        //  foreach (var serie in serie_list) {
        //      serie.clear();
        //  }
    }
}
