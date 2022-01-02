[Compact]
public class Monitor.Volume : Object {
    public string device;
    public string label;
    public string type;
    public string uuid;
    public string mount_point;
    public uint64 size;
    public uint64 free;
    public uint64 offset;

    // means the volume is only on one phisical disk
    public bool strict_affiliation { public get; private set; }

    public Gee.ArrayList<string?> slaves = new Gee.ArrayList <string?> ();


    public Volume (UDisks.Block block) {
        device = block.device;
        label = block.id_label;
        type = block.id_type;
        size = block.size;
        uuid = block.id_uuid;
    }

    public void add_slave (string? new_slave) {
        foreach (string slave in slaves) {
            if (!slave.contains (new_slave[0:3])) {
                debug ("Volume %s is not strictly affilitated with a certain disk", device);
                strict_affiliation = false;
            }
        }
        slaves.add (new_slave);
    }
}
