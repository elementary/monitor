public class Monitor.Chart : Gtk.Box {
    private LiveChart.Chart live_chart;
    private uint series_quantity;
    private Utils.Colors colors = new Utils.Colors ();
    public LiveChart.Config config;


    construct {
        this.add_css_class ("graph");

        vexpand = true;
        height_request = 120;

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
            left = -1
        };

        live_chart = new LiveChart.Chart (config);
        live_chart.hexpand = true;
        live_chart.legend.visible = false;
        live_chart.grid.visible = true;
        live_chart.background.visible = false;
        // live_chart.background.color = Gdk.RGBA () {
        // red = 1f, green = 1f, blue = 1f, alpha = 1f
        // }; // White background
    }

    public Chart (uint _series_quantity, bool smooth = true, double renderer_area_alfa = 0.2) {
        series_quantity = _series_quantity;

        if (smooth) {
            with_smooth_line (renderer_area_alfa);
        } else {
            with_straight_line (renderer_area_alfa);
        }
    }

    private Chart with_smooth_line (double renderer_area_alfa = 0.2) {
        for (int i = 0; i < series_quantity; i++) {
            var renderer = new LiveChart.SmoothLineArea (new LiveChart.Values (1000));
            renderer.area_alpha = renderer_area_alfa;
            var serie = new LiveChart.Serie (("Serie %d").printf (i), renderer);

            // The idea is to make area a bit less darker or lighter then the base line color
            // var color = colors.get_color_by_index (i);
            // renderer.region = new LiveChart.Region.between(0, double.MAX).with_line_color(color).with_area_color(color);

            serie.line.color = colors.get_color_by_index (i);

            live_chart.add_serie (serie);
        }
        append (live_chart);
        return this;
    }

    private Chart with_straight_line (double renderer_area_alfa = 0.5) {
        for (int i = 0; i < series_quantity; i++) {
            var renderer = new LiveChart.LineArea (new LiveChart.Values (1000));
            renderer.area_alpha = renderer_area_alfa;
            var serie = new LiveChart.Serie (("Serie %d").printf (i), renderer);

            serie.line.color = colors.get_color_by_index (i);
            live_chart.add_serie (serie);
        }
        append (live_chart);
        return this;
    }

    public void set_serie_color (int serie_number, Gdk.RGBA color) {
        try {
            live_chart.series[serie_number].line.color = color;
        } catch (LiveChart.ChartError e) {
            error (e.message);
        }
    }

    public void update (int serie_number, double value) {
        try {
            live_chart.series[serie_number].add (value);
        } catch (LiveChart.ChartError e) {
            error (e.message);
        }
    }

    public void preset_data (int serie_number, Gee.ArrayList<double ? > history) {
        var refresh_rate_in_ms = 2000;
        try {
            live_chart.add_unaware_timestamp_collection_by_index (serie_number, history, refresh_rate_in_ms);
        } catch (LiveChart.ChartError e) {
            error (e.message);
        }
    }

    public void clear () {
        // var series = live_chart.series;
        foreach (var serie in live_chart.series) {
            serie.clear ();
        }
    }

}
