public class Monitor.Preventor : Gtk.Stack {
    private Gtk.Box preventive_action_bar;
    private Gtk.Label confirmation_label;
    private Gtk.Button confirm_button;
    private Gtk.Button deny_button;

    private Gtk.Widget child_widget;

    public signal void confirmed (bool is_confirmed);

    construct {
        valign = Gtk.Align.END;

        preventive_action_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        preventive_action_bar.valign = Gtk.Align.START;
        preventive_action_bar.halign = Gtk.Align.END;
        preventive_action_bar.margin_top = 10;


        confirmation_label = new Gtk.Label (_("Are you sure you want to do this?"));
        confirmation_label.margin_end = 10;

        confirm_button = new Gtk.Button.with_label (_("Yes"));
        confirm_button.margin_end = 10;
        confirm_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        deny_button = new Gtk.Button.with_label (_("No"));

        preventive_action_bar.add (confirmation_label);
        preventive_action_bar.add (confirm_button);
        preventive_action_bar.add (deny_button);
    }

    public Preventor (Gtk.Widget _child, string name) {
        child_widget = _child;
        add_named (child_widget, name);
        add_named (preventive_action_bar, "preventive_action_bar");

        deny_button.clicked.connect (() => {
            set_transition_type (Gtk.StackTransitionType.SLIDE_UP);
            set_visible_child (child_widget);
            confirmed (false);
        });

        confirm_button.clicked.connect (() => {
            set_transition_type (Gtk.StackTransitionType.SLIDE_UP);
            set_visible_child (child_widget);
            confirmed (true);
        });
    }

    public void set_prevention (string confirmation_text) {
        set_transition_type (Gtk.StackTransitionType.SLIDE_DOWN);
        confirmation_label.set_text (_(confirmation_text));
        set_visible_child (preventive_action_bar);
    }

}
