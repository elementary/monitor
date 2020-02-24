public class CpuGraph : Dazzle.GraphView
    {
        private static CpuGraphModel graph_model;
        private Dazzle.GraphLineRenderer renderer;
        private Gdk.RGBA line_color_max;
        private Gdk.RGBA line_color_normal;

        class construct
        {
        }

        public CpuGraph(CpuGraphModel graph_model) {
            this.graph_model = graph_model;
            get_style_context().add_class("line_max");
            line_color_max = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line_max");
            get_style_context().add_class("line");
            line_color_normal = get_style_context().get_color(get_style_context().get_state());
            get_style_context().remove_class("line");
            get_style_context().add_class("big");

            set_model(graph_model);

            Gdk.RGBA linecol = Gdk.RGBA ();
            linecol.red = 1.0; linecol.green = 0.0; linecol.blue = 0.0; linecol.alpha = 1.0;        

            renderer = new Dazzle.GraphLineRenderer();
            renderer.stroke_color_rgba = linecol;
            renderer.line_width = 1;
            renderer.column = 0;

            add_renderer (renderer);

        }
    }
