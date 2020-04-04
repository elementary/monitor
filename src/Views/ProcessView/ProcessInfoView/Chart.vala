public class Monitor.Chart : Gtk.Box
    {
        private LiveChart.Serie serie;
        private LiveChart.Chart chart;
        private LiveChart.Config config;


        construct {
            vexpand = true;

            config = new LiveChart.Config();
            config.y_axis.unit = "%";
            config.y_axis.tick_interval = 25;
            config.y_axis.fixed_max = 100.0;

            chart = new LiveChart.Chart (config);
            chart.expand = true;
            chart.background.main_color = Gdk.RGBA() {red= 1, green= 1, blue= 1, alpha= 1}; //White background

            serie = new LiveChart.Serie("CPU 1 usage", new LiveChart.SmoothLineArea());
            serie.set_main_color({ 0.35, 0.8, 0.1, 1.0});

            chart.add_serie(serie);

            add (chart);
        }

        public void update (double value) {
            chart.add_value(serie, value);
        }
    }
