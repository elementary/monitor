public interface Monitor.IProcess : Object {

    public abstract signal void fd_permission_error (string error);

    /** Whether or not the PID leads to something */
    public abstract bool exists { get; public set; }

    // Full command from cmdline file
    public abstract string command { get; protected set; }

    // If process is an installed app, this will contain its name,
    // otherwise it is just a trimmed command
    public abstract string application_name { get; set; }

    // User id
    public abstract int uid { get; protected set; }

    public abstract string username { get; protected set; }

    public abstract Icon icon { get; set; }

    // Contains info about io
    public abstract ProcessIO io { get; public set; }

    // Contains status info
    public abstract ProcessStatus stat { get; public set; }

    public abstract ProcessStatusMemory statm { get; public set; }

    public abstract Gee.HashSet<string> open_files_paths { get; public set; }

    public abstract Gee.HashSet<int> children { get; public set; }

    public abstract double cpu_percentage { get; protected set; }

    protected abstract uint64 cpu_last_used { get; protected set; }

    // Memory usage of the process, measured in KiB.
    public abstract uint64 mem_usage { get; protected set; }
    public abstract double mem_percentage { get; protected set; }

    public abstract uint64 last_total { get; protected set; }

    private abstract const int HISTORY_BUFFER_SIZE = 30;
    public abstract Gee.ArrayList<double ? > cpu_percentage_history { get; protected set; }
    public abstract Gee.ArrayList<double ? > mem_percentage_history { get; protected set; }

    protected abstract int get_uid ();

    public abstract bool update (uint64 cpu_total, uint64 cpu_last_total);

    public abstract bool kill ();
    public abstract bool end ();

    public abstract bool get_children_pids ();

    public abstract bool parse_io ();

    public abstract bool parse_stat ();

    public abstract bool parse_statm ();

    public abstract bool get_open_files ();

    public abstract bool read_cmdline ();

    public abstract void get_usage (uint64 cpu_total, uint64 cpu_last_total);
}
