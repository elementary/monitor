public class Monitor.ContainerView : Gtk.Box {
    private ContainerManager container_manager;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
    }

    public ContainerView () {

        container_manager = new ContainerManager ();

        update ();

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        var wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        wrapper.expand = true;
        scrolled_window.add (wrapper);

        add (scrolled_window);
    }

    public async void update () {
        var api_containers = yield container_manager.list_containers ();
        
        for (var i = 0; i < api_containers.length; i++) {
            var container = api_containers[i];

            debug("%s", container.name);
        }
    }

}
