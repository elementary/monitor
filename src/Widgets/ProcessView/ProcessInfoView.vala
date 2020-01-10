public class Monitor.ProcessInfoView : Gtk.HBox {
    //  public Process process;

    public ProcessInfoView() {
        //  process = _process;

        var process_name = new Gtk.Label("some_process");

        add (process_name);
        
    }
}