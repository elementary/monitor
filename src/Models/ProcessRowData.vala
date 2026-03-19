
/* This class holds data from Process class to use in the ColumnView */
public class Monitor.ProcessRowData : GLib.Object {
    public Icon icon { get; set; }
    public string name { get; set; }
    public int cpu { get; set; }
    public uint64 memory { get; set; }
    public int pid { get; set; }
    public string cmd { get; set; }
}