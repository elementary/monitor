public class Monitor.ContainerInfoHeader : Gtk.Grid {
    private Gtk.Image icon;
    public Gtk.Label state;
    public Gtk.Label container_name;
    public Gtk.Label container_image;
    public LabelRoundy pid;

    public LabelRoundy ppid;
    public LabelRoundy pgrp;
    public LabelRoundy nice;
    public LabelRoundy priority;
    public LabelRoundy num_threads;
    public LabelRoundy username;

    private Regex ? regex;

    construct {
        column_spacing = 12;

        /* *INDENT-OFF* */
        regex = /(?i:^.*\.(xpm|png)$)/; // vala-lint=space-before-paren,
        /* *INDENT-ON* */

        icon = new Gtk.Image.from_icon_name ("application-x-executable");
        icon.set_pixel_size (64);
        icon.valign = Gtk.Align.END;

        state = new Gtk.Label ("?");
        state.halign = Gtk.Align.START;
        state.get_style_context ().add_class ("state_badge");

        var icon_container = new Gtk.Fixed ();
        icon_container.put (icon, 0, 0);
        icon_container.put (state, -5, 48);

        container_name = new Gtk.Label (_("N/A"));
        container_name.get_style_context ().add_class ("h2");
        container_name.ellipsize = Pango.EllipsizeMode.END;
        container_name.tooltip_text = _("N/A");
        container_name.halign = Gtk.Align.START;
        container_name.valign = Gtk.Align.START;

        pid = new LabelRoundy (_("PID"));
        nice = new LabelRoundy (_("NI"));
        priority = new LabelRoundy (_("PRI"));
        num_threads = new LabelRoundy (_("THR"));
        // ppid = new LabelRoundy (_("PPID"));
        // pgrp = new LabelRoundy (_("PGRP"));

        // TODO: tooltip_text UID
        username = new LabelRoundy ("");

        //  var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        //  wrapper.add (pid);
        //  wrapper.add (priority);
        //  wrapper.add (nice);
        //  wrapper.add (num_threads);
        //  wrapper.add (username);

        container_image = new Gtk.Label (Utils.NO_DATA);

        container_image.get_style_context ().add_class ("dim-label");
        container_image.get_style_context ().add_class ("image");
        container_image.max_width_chars = 48;
        container_image.ellipsize = Pango.EllipsizeMode.END;
        container_image.halign = Gtk.Align.START;

        attach (icon_container, 0, 0, 1, 2);
        attach (container_name, 1, 0, 3, 1);
        attach (container_image, 1, 1, 1, 1);
    }

    public void update (DockerContainer container) {
        container_name.set_text (container.name);
        container_name.tooltip_text = container.id;
        container_image.set_text (container.image);
        //  pid.set_text (process.stat.pid.to_string ());
        //  nice.set_text (process.stat.nice.to_string ());
        //  priority.set_text (process.stat.priority.to_string ());

        //  if (process.uid == 0) {
        //      username.val.get_style_context ().add_class ("username-root");
        //      username.val.get_style_context ().remove_class ("username-other");
        //      username.val.get_style_context ().remove_class ("username-current");
        //  } else if (process.uid == (int) Posix.getuid ()) {
        //      username.val.get_style_context ().add_class ("username-current");
        //      username.val.get_style_context ().remove_class ("username-other");
        //      username.val.get_style_context ().remove_class ("username-root");
        //  } else {
        //      username.val.get_style_context ().add_class ("username-other");
        //      username.val.get_style_context ().remove_class ("username-root");
        //      username.val.get_style_context ().remove_class ("username-current");
        //  }

        //  username.set_text (process.username);
        //  num_threads.set_text (process.stat.num_threads.to_string ());
        //  state.set_text (process.stat.state);
        //  state.tooltip_text = set_state_tooltip ();
        //  num_threads.set_text (process.stat.num_threads.to_string ());
        //  set_icon (process);
    }
}
