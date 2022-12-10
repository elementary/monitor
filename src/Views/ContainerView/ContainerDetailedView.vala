public class Monitor.ContainerDetailedView : Gtk.Box {

    private DockerContainer container;

    construct {
        this.expand = true;
        this.width_request = 200;
    }

    private Gtk.Widget build_container_name () {
        var container_name = new Gtk.Label (this.container.name);
        container_name.get_style_context ().add_class ("primary");
        container_name.halign = Gtk.Align.START;

        return container_name;
    }

    public void setup (DockerContainer container) {
        this.add (this.build_container_name ());
    }
}