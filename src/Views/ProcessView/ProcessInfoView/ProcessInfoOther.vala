public class Monitor.ProcessInfoOther : Gtk.Grid  {
    private Gtk.Label rchar_label;
    private Gtk.Label wchar_label;
    private Gtk.Label syscr_label;
    private Gtk.Label syscw_label;
    private Gtk.Label write_bytes_label;
    private Gtk.Label read_bytes_label;
    private Gtk.Label cancelled_write_bytes_label;


    construct {
        column_spacing = 12;
        row_spacing = 12;
        column_homogeneous = true;
        row_homogeneous = true;

        var io_label = new Gtk.Label (_("IO"));
        io_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        
        var net_label = new Gtk.Label ( _("NET"));
        net_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var rchar_desc_label = create_label (_("characters read"));
        rchar_label = create_label (_("N/A"));

        var wchar_desc_label = create_label (_("characters written"));
        wchar_label = create_label (_("N/A"));

        var syscr_desc_label = create_label (_("read syscalls"));
        syscr_label = create_label (_("N/A"));

        var syscw_desc_label = create_label (_("write syscalls"));
        syscw_label = create_label (_("N/A"));

        var write_bytes_desc_label = create_label (_("Read bytes"));
        write_bytes_label = create_label (_("N/A"));

        var read_bytes_desc_label = create_label (_("Written bytes"));
        read_bytes_label = create_label (_("N/A"));

        var cancelled_write_bytes_desc_label = create_label (_("Cancelled write_bytes"));
        cancelled_write_bytes_label = create_label (_("N/A"));

        attach (io_label, 0, 0, 1, 2);
        attach (rchar_desc_label, 0, 1, 1, 2);
        attach (wchar_desc_label, 0, 2, 1, 2);
        attach (syscr_desc_label, 0, 3, 1, 2);
        attach (syscw_desc_label, 0, 4, 1, 2);
        attach (write_bytes_desc_label, 0, 5, 1, 2);
        attach (read_bytes_desc_label, 0, 6, 1, 2);
        attach (cancelled_write_bytes_desc_label, 0, 7, 1, 2);

        attach (rchar_label, 1, 1, 1, 2);
        attach (wchar_label, 1, 2, 1, 2);
        attach (syscr_label, 1, 3, 1, 2);
        attach (syscw_label, 1, 4, 1, 2);
        attach (write_bytes_label, 1, 5, 1, 2);
        attach (read_bytes_label, 1, 6, 1, 2);
        attach (cancelled_write_bytes_label, 1, 7, 1, 2);


        attach (net_label, 2, 0, 1, 2);
    }

    private Gtk.Label create_label (string text) {
        var label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        return label;
    }

    public void update (Process process) {
        rchar_label.set_text (process.io.rchar.to_string());
        wchar_label.set_text (process.io.wchar.to_string());
        syscr_label.set_text (process.io.syscr.to_string());
        syscw_label.set_text (process.io.syscw.to_string());
        write_bytes_label.set_text (process.io.write_bytes.to_string());
        read_bytes_label.set_text (process.io.read_bytes.to_string());
        cancelled_write_bytes_label.set_text (process.io.cancelled_write_bytes.to_string());

    }

}