public class Monitor.ProcessInfoIOStats : Gtk.Grid {
    private Gtk.Label rchar_label;
    private Gtk.Label wchar_label;
    private Gtk.Label syscr_label;
    private Gtk.Label syscw_label;
    private Gtk.Label write_bytes_label;
    private Gtk.Label read_bytes_label;
    private Gtk.Label cancelled_write_bytes_label;

    private OpenFilesListBox open_files_listbox;

    construct {
        column_spacing = 6;
        row_spacing = 6;
        column_homogeneous = true;
        row_homogeneous = false;

        var opened_files_label = create_label (_("Opened files"));
        opened_files_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        opened_files_label.margin_top = 24;
       
        var characters_label = create_label (_("Characters"));
        characters_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        rchar_label = create_label (_("N/A"));
        wchar_label = create_label (_("N/A"));

        var system_calls_label = create_label (_("System calls"));
        system_calls_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        syscr_label = create_label (_("N/A"));
        syscw_label = create_label (_("N/A"));

        var io_label = create_label (_("Read/Written"));
        io_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        write_bytes_label = create_label (_("N/A"));
        read_bytes_label = create_label (_("N/A"));

        var cancelled_write_label = create_label (_("Cancelled write"));
        cancelled_write_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        cancelled_write_bytes_label = create_label (Utils.NO_DATA);

        attach (io_label, 0, 1, 1, 1);
        attach (create_label_with_icon(read_bytes_label, "go-up-symbolic"), 0, 2, 1, 1);
        attach (create_label_with_icon(write_bytes_label, "go-down-symbolic"), 0, 3, 1, 1);

        attach (cancelled_write_label, 1, 1, 1, 1);
        attach (cancelled_write_bytes_label, 1, 2, 1, 1);

        attach (opened_files_label, 0, 3, 3, 1);

        open_files_listbox = new OpenFilesListBox ();
        attach (open_files_listbox, 0, 4, 3, 1);
    }

    public ProcessInfoIOStats() {
        
    }

    public void update (Process process) {
        write_bytes_label.set_text (Utils.HumanUnitFormatter.double_bytes_to_human(process.io.write_bytes));
        read_bytes_label.set_text (Utils.HumanUnitFormatter.double_bytes_to_human(process.io.read_bytes));
        cancelled_write_bytes_label.set_text (Utils.HumanUnitFormatter.double_bytes_to_human(process.io.cancelled_write_bytes));
        
        open_files_listbox.update (process);
    }

    private Gtk.Label create_label (string text) {
        var label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        return label;
    }

    private Gtk.Image create_icon (string icon_name) {
        var icon = new Gtk.Image ();
        icon.gicon = new ThemedIcon (icon_name);
        icon.halign = Gtk.Align.START;
        icon.pixel_size = 16;
        return icon;
    }

    private Gtk.Grid create_label_with_icon (Gtk.Label label, string icon_name) {
        var grid = new Gtk.Grid ();
        grid.column_spacing = 2;
        grid.attach (create_icon (icon_name), 0, 0, 1, 1);
        grid.attach (label, 1, 0, 1, 1);
        return grid;
    }
}