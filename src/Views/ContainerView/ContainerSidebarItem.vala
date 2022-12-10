class Monitor.ContainerSidebarItem : Gtk.ListBoxRow {
    public DockerContainer container;

    public ContainerSidebarItem (DockerContainer service) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        this.container = service;
        this.activatable = false;
        this.selectable = true;
        this.get_style_context ().add_class ("side-bar-item");
        this.add (box);

        //
        var container_name = new Gtk.Label (service.name);

        container_name.get_style_context ().add_class ("primary");
        container_name.get_style_context ().add_class ("name");
        container_name.max_width_chars = 48;
        container_name.ellipsize = Pango.EllipsizeMode.END;
        container_name.halign = Gtk.Align.START;
        box.pack_start (container_name, false);

        //
        var container_image = new Gtk.Label (service.image);

        container_image.get_style_context ().add_class ("dim-label");
        container_image.get_style_context ().add_class ("image");
        container_image.max_width_chars = 48;
        container_image.ellipsize = Pango.EllipsizeMode.END;
        container_image.halign = Gtk.Align.START;
        box.pack_end (container_image, false);

        show_all ();
    }
}