public class Monitor.Preventor : Gtk.Box {
    private Gtk.Box preventive_action_bar;
    private Gtk.Label confirmation_label;
    private Gtk.Button confirm_button;
    private Gtk.Button deny_button;

    private Gtk.Stack stack;

    public signal void confirmed (bool is_confirmed);

    construct {
        valign = Gtk.Align.END;
        halign = Gtk.Align.END;

        preventive_action_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0){
            valign = Gtk.Align.START,
            halign = Gtk.Align.END,
            margin_top = 10
        };

        confirmation_label = new Gtk.Label (_("Are you sure you want to do this?")){
            margin_end = 10
        };

        confirm_button = new Gtk.Button.with_label (_("Yes")) {
            margin_end = 10
        };
        confirm_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        deny_button = new Gtk.Button.with_label (_("No"));

        preventive_action_bar.append (confirmation_label);
        preventive_action_bar.append (confirm_button);
        preventive_action_bar.append (deny_button);
    }

    public Preventor (Gtk.Widget child_widget, string name) {
        stack  = new Gtk.Stack ();
        append (stack);
        stack.add_named (child_widget, name);
        stack.add_named (preventive_action_bar, "preventive_action_bar");

        deny_button.clicked.connect (() => {
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP);
            stack.set_visible_child (child_widget);
            confirmed (false);
        });

        confirm_button.clicked.connect (() => {
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP);
            stack.set_visible_child (child_widget);
            confirmed (true);
        });
    }

    public void set_prevention (string confirmation_text) {
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_DOWN);
        confirmation_label.set_text (_(confirmation_text));
        stack.set_visible_child (preventive_action_bar);
        preventive_action_bar.visible = true;
    }

}
