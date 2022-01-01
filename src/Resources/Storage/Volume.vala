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

    public Volume (UDisks.Block block) {
        device = block.device;
        label = block.id_label;
        type = block.id_type;
        size = block.size;
        uuid = block.id_uuid;
    }
}
