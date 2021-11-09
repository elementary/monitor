public interface  Monitor.IHwmonInterfacePathsParser : Object {

    public abstract string name { get; protected set; }

    protected abstract Gee.HashSet<string> all_paths { get; protected set; }


    public abstract void parse ();

    public virtual void add_path (string path) {
        all_paths.add (path);
    }

    public virtual string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n", "");
        } catch (FileError e) {
            warning ("%s", e.message);
            return "";
        }
    }
}
