public class Monitor.PathsGPU : Object {

    public string name;

    public Gee.HashMap<int, PathsTemp> paths_temp = new Gee.HashMap<int, PathsTemp>();

    private Gee.HashSet<string> all_paths = new Gee.HashSet<string>();

    construct {

    }

    public void parse () {
        foreach (var path  in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = basename;
            } else if (basename.contains ("temp")) {
                debug ("🌡 Found GPU temperature interface: %s", basename);
                if (!paths_temp.has_key (basename[4])) {
                    paths_temp.set (basename[4], new PathsTemp ());
                    //  debug ("- Created struct");
                }

                if (basename.contains ("label")) {
                    paths_temp.get (basename[4]).label = path;
                } else if (basename.contains ("input")) {
                    paths_temp.get (basename[4]).input = path;
                } else if (basename.contains ("crit")) {
                    paths_temp.get (basename[4]).crit = path;
                } else if (basename.contains ("crit_hyst")) {
                    paths_temp.get (basename[4]).crit_hyst = path;
                } else if (basename.contains ("emergency")) {
                    paths_temp.get (basename[4]).emergency = path;
                }
            }
        }
    }

    public void add_path (string path) {
        all_paths.add (path);
    }
}