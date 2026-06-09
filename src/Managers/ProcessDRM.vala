/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessDRM {

    private string driver;

    /**
     * Time spent busy in nanoseconds by the render engine executing
     * workloads from the last time it was read
     */
    private uint64 last_engine_render;
    private uint64 last_engine_gfx;

    private uint64 engine_gfx;
    private uint64 engine_render;

    // Xe driver related fields
    private uint64 cycles_rcs = 0;
    private uint64 cycles_rcs_total = 0;
    private uint64 cycles_bcs = 0;
    private uint64 cycles_bcs_total = 0;
    private uint64 cycles_vcs = 0;
    private uint64 cycles_vcs_total = 0;
    private uint64 cycles_ccs = 0;
    private uint64 cycles_ccs_total = 0;
    private uint64 cycles_vecs = 0;
    private uint64 cycles_vecs_total = 0;

    private uint64 delta_rcs = 0;
    private uint64 delta_total_rcs = 0;

    private uint64 delta_ccs = 0;
    private uint64 delta_total_ccs = 0;

    public double gpu_percentage { get; private set; }

    private int pid;
    private int update_interval;
    private Gee.ArrayList<GLib.File> drm_files;

    public ProcessDRM (int pid, int update_interval) {
        this.pid = pid;
        this.update_interval = update_interval;

        last_engine_render = 0;
        last_engine_gfx = 0;

        get_drm_files ();
    }

    private void get_drm_files () {
        string path_fdinfo = "/proc/%d/fdinfo".printf (pid);
        string path_fd = "/proc/%d/fd".printf (pid);

        drm_files = new Gee.ArrayList<GLib.File ?> ();

        try {
            Dir dir = Dir.open (path_fdinfo, 0);
            string ? name = null;

            while ((name = dir.read_name ()) != null) {

                // skip standard fds
                if (name == "0" || name == "1" || name == "2") {
                    continue;
                }
                string path = Path.build_filename (path_fdinfo, name);

                int fd_dir_fd = Posix.open (path_fd, Posix.O_RDONLY | Posix.O_DIRECTORY);
                if (fd_dir_fd == -1) {
                    warning ("Cannot open file descriptor: %s", path_fd);
                    continue;
                }

                bool is_drm = is_drm_fd (fd_dir_fd, name);
                Posix.close (fd_dir_fd);

                if (is_drm) {
                    var drm_file = File.new_for_path (path);
                    drm_files.add (drm_file);
                    debug ("Found DRM file: %s", path);
                }
            }
        } catch (FileError err) {
            // prevent flooding logs with permission errors
            if (!(err is FileError.ACCES)) {
                warning (err.message);
            }
        }
        // debug ("Found %d drm fdinfo files for pid %d", drm_files.size, pid);
    }

    public void update () {
        if (drm_files.size == 0) {
            gpu_percentage = 0;
            return;
        }

        foreach (var drm_file in drm_files) {
            try {
                debug ("Reading fdinfo from: %s", drm_file.get_path ());
                var dis = new DataInputStream (drm_file.read ());
                string ? line;

                while ((line = dis.read_line ()) != null) {
                    parse_drm_line (line);
                }
            } catch (Error err) {
                if (!(err is FileError.ACCES)) {
                    warning ("Can't read fdinfo: '%s' %d", err.message, err.code);
                }
            }
            break;
        }

        switch (driver) {
        case "i915":
            update_engine (ref engine_render, ref last_engine_render);
            break;
        case "xe":
            var pre = (float) delta_rcs / (float) delta_total_rcs;
            gpu_percentage = delta_total_rcs > 0 ? 100 * (pre.clamp (0.0f, 1.0f)) : 0;
            break;
        case "amdgpu":
             update_engine (ref engine_gfx, ref last_engine_gfx);
             break;
        default:
            // Handle default case
            break;
        }

    }

    private void update_engine (ref uint64 engine, ref uint64 last_engine) {
        if (last_engine != 0) {
            gpu_percentage = calculate_percentage (engine, last_engine, update_interval);
        }
        last_engine = engine;
    }

    private void update_cycles (string line, ref uint64 last_cycles, ref uint64 delta) {
        var cycles = uint64.parse (line.strip ().split (" ")[0]);
        delta = cycles > last_cycles ? cycles - last_cycles : 0;
        // debug ("pid %d Cycles: %llu, Last Cycles: %llu, Delta: %llu", pid, cycles, last_cycles, delta);
        last_cycles = cycles;
    }

    private static double calculate_percentage (uint64 engine, uint64 last_engine, int interval) {
        // Since values in the files are in nanoseconds, it is also needed to convert interval to nanoseconds (10^9)
        return 100 * ((double) (engine - last_engine)) / (interval * 1e9);
    }

    // Based on nvtop
    // https://github.com/Syllo/nvtop/blob/4bf5db248d7aa7528f3a1ab7c94f504dff6834e4/src/extract_processinfo_fdinfo.c#L88
    private static bool is_drm_fd (int fd_dir_fd, string name) {
        Posix.Stat stat;
        int ret = Posix.fstatat (fd_dir_fd, name, out stat, 0);
        return ret == 0 && (stat.st_mode & Posix.S_IFMT) == Posix.S_IFCHR && Posix.major (stat.st_rdev) == 226;
    }

    private void parse_drm_line (string line) {
        var splitted_line = line.split (":");
        switch (splitted_line[0]) {
        case "drm-driver":
            driver = splitted_line[1].strip ();
            break;
        case "drm-engine-gfx":
            engine_gfx = uint64.parse (splitted_line[1].strip ().split (" ")[0]);
            break;
        // for i915 there is only drm-engine-render to check
        case "drm-engine-render":
            engine_render = uint64.parse (splitted_line[1].strip ().split (" ")[0]);
            break;
        // Xe driver specific entries
        case "drm-cycles-ccs":
            update_cycles (splitted_line[1], ref cycles_ccs, ref delta_ccs);
            break;
        case "drm-total-cycles-ccs":
            update_cycles (splitted_line[1], ref cycles_ccs_total, ref delta_total_ccs);
            break;
        case "drm-cycles-rcs":
            // debug ("path: %s, line: %s", drm_file.get_path (), line);
            update_cycles (splitted_line[1], ref cycles_rcs, ref delta_rcs);
            break;
        case "drm-total-cycles-rcs":
            // debug ("path: %s, line: %s", drm_file.get_path (), line);
            update_cycles (splitted_line[1], ref cycles_rcs_total, ref delta_total_rcs);
            break;
        default:
            // Ignore other entries
            break;
        }
    }

}
