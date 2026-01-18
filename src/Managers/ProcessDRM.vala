/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessDRM {
    /** Time spent busy in nanoseconds by the render engine executing
     * workloads from the last time it was read
     */
    private uint64 last_engine_render;
    private uint64 last_engine_gfx;


    public double gpu_percentage { get; private set; }

    private int pid;
    private int update_interval;

    public ProcessDRM (int pid, int update_interval) {
        this.pid = pid;
        this.update_interval = update_interval;

        last_engine_render = 0;
        last_engine_gfx = 0;
    }

    public void update () {
        string path_fdinfo = "/proc/%d/fdinfo".printf (pid);
        string path_fd = "/proc/%d/fd".printf (pid);


        var drm_files = new Gee.ArrayList<GLib.File ?> ();

        try {
            Dir dir = Dir.open (path_fdinfo, 0);
            string ? name = null;

            while ((name = dir.read_name ()) != null) {

                // skip standard fds
                if (name == "0" || name == "1" || name == "2") {
                    continue;
                }
                string path = Path.build_filename (path_fdinfo, name);

                int fd_dir_fd = Posix.open (path_fd, Posix.O_RDONLY | Posix.O_DIRECTORY, 0);
                bool is_drm = is_drm_fd (fd_dir_fd, name);
                Posix.close (fd_dir_fd);

                if (is_drm) {
                    var drm_file = File.new_for_path (path);
                    drm_files.add (drm_file);
                }
            }
        } catch (FileError err) {
            // prevent flooding logs with permission errors
            if (!(err is FileError.ACCES)) {  
                warning (err.message);  
            } 
        }

        foreach (var drm_file in drm_files) {
            try {
                var dis = new DataInputStream (drm_file.read ());
                string ? line;

                while ((line = dis.read_line ()) != null) {
                    var splitted_line = line.split (":");
                    switch (splitted_line[0]) {
                    case "drm-engine-gfx":
                        update_engine (splitted_line[1], ref last_engine_gfx);
                        break;
                    // for i915 there is only drm-engine-render to check
                    case "drm-engine-render":
                        update_engine (splitted_line[1], ref last_engine_render);
                        break;
                    default:
                        // Ignore other entries
                        break;
                    }
                }
            } catch (Error err) {
                if (!(err is FileError.ACCES)) {  
                    warning ("Can't read fdinfo: '%s' %d", err.message, err.code); 
                } 
            }
            break;
        }
    }

    private void update_engine (string line, ref uint64 last_engine) {
        var engine = uint64.parse (line.strip ().split (" ")[0]);
        if (last_engine != 0) {
            gpu_percentage = calculate_percentage (engine, last_engine, update_interval);
        }
        last_engine = engine;
    }

    private static double calculate_percentage (uint64 engine, uint64 last_engine, int interval) {
        return 100 * ((double) (engine - last_engine)) / (interval * 1e9);
    }

    // Based on nvtop
    // https://github.com/Syllo/nvtop/blob/4bf5db248d7aa7528f3a1ab7c94f504dff6834e4/src/extract_processinfo_fdinfo.c#L88
    static bool is_drm_fd (int fd_dir_fd, string name) {
        Posix.Stat stat;
        int ret = Posix.fstatat (fd_dir_fd, name, out stat, 0);
        return ret == 0 && (stat.st_mode & Posix.S_IFMT) == Posix.S_IFCHR && Posix.major (stat.st_rdev) == 226;
    }

}
