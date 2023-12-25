public class Monitor.ProcessWorkaround : IProcess, GLib.Object {

    // Whether or not the PID leads to something
    public bool exists { get; private set; }

    // Full command from cmdline file
    public string command { get; private set; }

    // If process is an installed app, this will contain its name,
    // otherwise it is just a trimmed command
    public string application_name { get; private set; }

    // User id
    public int uid { get; private set; }

    public string username { get; private set; default = Utils.NO_DATA; }

    Icon _icon;
    public Icon icon {
        get {
            return _icon;
        }
        set {
            if (value == null) {
                _icon = ProcessUtils.get_default_icon ();
            } else {
                _icon = value;
            }
        }
    }

    // Contains info about io
    public ProcessIO io { get; private set; }

    // Contains status info
    public ProcessStatus stat { get; private set; }

    public ProcessStatusMemory statm { get; private set; }

    public Gee.HashSet<string> open_files_paths { get; private set; }

    public Gee.HashSet<int> children { get; private set; default = new Gee.HashSet<int> (); }

    /**
     * CPU usage of this process from the last time that it was updated, measured in percent
     *
     * Will be 0 on first update.
     */
    public double cpu_percentage { get; private set; }

    private uint64 cpu_last_used { get; private set; }

    // Memory usage of the process, measured in KiB.
    public uint64 mem_usage { get; private set; }
    public double mem_percentage { get; private set; }

    private uint64 last_total { get; private set; }

    private const int HISTORY_BUFFER_SIZE = 30;
    public Gee.ArrayList<double ? > cpu_percentage_history { get; private set; default = new Gee.ArrayList<double ? > (); }
    public Gee.ArrayList<double ? > mem_percentage_history { get; private set; default = new Gee.ArrayList<double ? > (); }



    // Construct a new process
    public ProcessWorkaround (int _pid) {
        _icon = ProcessUtils.get_default_icon ();

        open_files_paths = new Gee.HashSet<string> ();

        last_total = 0;

        io = {};
        stat = {};
        stat.pid = _pid;

        // getting uid
        uid = get_uid ();

        // getting username
        // @TOFIX: Can't get username for postgres which
        // is started from docker (?)
        unowned Posix.Passwd passwd = Posix.getpwuid (uid);
        if (passwd != null) {
            username = passwd.pw_name;
        }

        exists = parse_stat () && read_cmdline ();
        get_children_pids ();
        get_usage (0, 1);
    }

    private int get_uid () {
        var process_provider = ProcessProvider.get_default ();
        string ? status = process_provider.pids_status.get (this.stat.pid);
        var status_line = status.split ("\n");
        return int.parse (status_line[8].split ("\t")[1]);
    }

    // Kills the process
    public bool kill () {
        // Sends a kill signal that cannot be ignored
        if (Posix.kill (stat.pid, Posix.Signal.KILL) == 0) {
            return true;
        }
        return false;
    }

    // Ends the process
    public bool end () {
        // Sends a terminate signal
        if (Posix.kill (stat.pid, Posix.Signal.TERM) == 0) {
            return true;
        }
        return false;
    }

    private bool get_children_pids () {
        var process_provider = ProcessProvider.get_default ();
        string ? children_content = process_provider.pids_children.get (this.stat.pid);

        var splitted_children_pids = children_content.split (" ");
        foreach (var child in splitted_children_pids) {
            this.children.add (int.parse (child));
        }
        return true;
    }

    private bool parse_io () {
        var process_provider = ProcessProvider.get_default ();
        string ? io_stats = process_provider.pids_io.get (this.stat.pid);

        if (io_stats == "") return false;

        foreach (string line in io_stats.split ("\n")) {
            if (line == "") continue;
            var splitted_line = line.split (":");
            switch (splitted_line[0]) {
            case "wchar":
                io.wchar = uint64.parse (splitted_line[1]);
                break;
            case "rchar":
                io.rchar = uint64.parse (splitted_line[1]);
                break;
            case "syscr":
                io.syscr = uint64.parse (splitted_line[1]);
                break;
            case "syscw":
                io.syscw = uint64.parse (splitted_line[1]);
                break;
            case "read_bytes":
                io.read_bytes = uint64.parse (splitted_line[1]);
                break;
            case "write_bytes":
                io.write_bytes = uint64.parse (splitted_line[1]);
                break;
            case "cancelled_write_bytes":
                io.cancelled_write_bytes = uint64.parse (splitted_line[1]);
                break;
            default:
                warning ("Unknown value in /proc/%d/io", stat.pid);
                break;
            }
        }

        return true;
    }

    // Reads the /proc/%pid%/stat file and updates the process with the information therein.
    private bool parse_stat () {
        var process_provider = ProcessProvider.get_default ();
        string ? stat_contents = process_provider.pids_stat.get (this.stat.pid);

        if (stat_contents == null) return false;

        // debug (stat_contents);

        // Split the contents into an array and parse each value that we care about

        // But first we have to extract the command name, since it might include spaces
        // First find the command in stat file. It is inside `(command)`

        /* *INDENT-OFF* */
        Regex regex = /\((.*?)\)/; // vala-lint=space-before-paren,
        /* *INDENT-ON* */

        MatchInfo match_info;
        regex.match (stat_contents, 0, out match_info);
        string matched_command = match_info.fetch (0);

        // Remove command from stat_contents
        stat_contents = stat_contents.replace (matched_command, "");

        // split the string and extract some stats
        var splitted_stat = stat_contents.split (" ");
        stat.comm = matched_command[1 : -1];

        stat.state = splitted_stat[2];
        stat.ppid = int.parse (splitted_stat[3]);
        stat.pgrp = int.parse (splitted_stat[4]);
        stat.priority = int.parse (splitted_stat[17]);
        stat.nice = int.parse (splitted_stat[18]);
        stat.num_threads = int.parse (splitted_stat[19]);

        return true;
    }

    private bool parse_statm () {
        var process_provider = ProcessProvider.get_default ();
        string ? statm_contents = process_provider.pids_stat.get (this.stat.pid);

        if (statm_contents == null) return false;

        var splitted_statm = statm_contents.split (" ");
        statm.size = int.parse (splitted_statm[0]);
        statm.resident = int.parse (splitted_statm[1]);
        statm.shared = int.parse (splitted_statm[2]);
        statm.trs = int.parse (splitted_statm[3]);
        statm.lrs = int.parse (splitted_statm[4]);
        statm.drs = int.parse (splitted_statm[5]);
        statm.dt = int.parse (splitted_statm[6]);

        return true;
    }

    private bool get_open_files () {
        // try {
        // string directory = "/proc/%d/fd".printf (stat.pid);
        // Dir dir = Dir.open (directory, 0);
        // string ? name = null;
        // while ((name = dir.read_name ()) != null) {
        // string path = Path.build_filename (directory, name);

        // if (FileUtils.test (path, FileTest.IS_SYMLINK)) {
        // string real_path = FileUtils.read_link (path);
        //// debug(content);
        // open_files_paths.add (real_path);
        // }
        // }
        // } catch (FileError err) {
        // if (err is FileError.ACCES) {
        // fd_permission_error (err.message);
        // } else {
        // warning (err.message);
        // }
        // }
        return true;
    }

    /**
     * Reads the /proc/%pid%/cmdline file and updates from the information contained therein.
     */
    private bool read_cmdline () {
        var process_provider = ProcessProvider.get_default ();
        string ? cmdline = process_provider.pids_cmdline.get (this.stat.pid);


        if (cmdline == null) {
            return false;
        }

        if (cmdline.length <= 0) {
            // if cmdline has 0 length we look into stat file
            // useful for kworker processes
            command = stat.comm;
            return true;
        }

        command = cmdline;

        return true;
    }

    private void get_usage (uint64 cpu_total, uint64 cpu_last_total) {
        // Get CPU usage by process
        GTop.ProcTime proc_time;
        GTop.get_proc_time (out proc_time, stat.pid);
        cpu_percentage = 100 * ((double) (proc_time.rtime - cpu_last_used)) / (cpu_total - cpu_last_total);
        cpu_last_used = proc_time.rtime;

        // Making CPU history
        if (cpu_percentage_history.size == HISTORY_BUFFER_SIZE) {
            cpu_percentage_history.remove_at (0);
        }
        cpu_percentage_history.add (cpu_percentage);

        // Get memory usage by process
        GTop.Memory mem;
        GTop.get_mem (out mem);

        GTop.ProcMem proc_mem;
        GTop.get_proc_mem (out proc_mem, stat.pid);
        mem_usage = (proc_mem.resident - proc_mem.share) / 1024; // in KiB

        // also if it is using X Window Server
        if (Gdk.Display.get_default () is Gdk.X11.Display) {
            Wnck.ResourceUsage resu = Wnck.ResourceUsage.pid_read (Gdk.Display.get_default (), stat.pid);
            mem_usage += (resu.total_bytes_estimate / 1024);
        }

        var total_installed_memory = (double) mem.total / 1024;
        mem_percentage = (mem_usage / total_installed_memory) * 100;

        // Making RAM history
        if (mem_percentage_history.size == HISTORY_BUFFER_SIZE) {
            mem_percentage_history.remove_at (0);
        }
        mem_percentage_history.add (mem_percentage);
    }

    // Updates the process to get latest information
    // Returns if the update was successful
    public bool update (uint64 cpu_total, uint64 cpu_last_total) {
        exists = parse_stat ();
        if (exists) {
            get_usage (cpu_total, cpu_last_total);
            parse_io ();
            parse_statm ();
            get_open_files ();
        }
        return exists;
    }

}
