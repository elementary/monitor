public class Monitor.ProcessInfoOther : Gtk.Grid  {





    private Gtk.Label create_label (string text) {
        var label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        return label;
    }



}