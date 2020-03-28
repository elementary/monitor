public class Monitor.Graph : Dazzle.GraphView
    {
        private Dazzle.GraphLineRenderer renderer;

        construct {
            expand = true;
            valign = Gtk.Align.START;
            height_request = 60;

            Gdk.RGBA linecol = Gdk.RGBA ();
            linecol.red = 1.0;
            linecol.green = 0.0;
            linecol.blue = 0.0;
            linecol.alpha = 1.0;

            renderer = new Dazzle.GraphLineRenderer();
            renderer.stroke_color_rgba = linecol;
            renderer.line_width = 1;
            renderer.column = 0;

            add_renderer (renderer);
        }
    }
