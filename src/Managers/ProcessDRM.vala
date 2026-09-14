/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessDRM : GLib.Object {

    private string driver;

    /**
     * Time spent busy in nanoseconds by the render engine executing
     * workloads from the last time it was read
     */
    private uint64 last_engine_render = 0;
    private uint64 last_engine_gfx = 0;

    private uint64 engine_gfx;
    private uint64 engine_render;

    // Xe driver related fields
    private uint64 cycles_rcs = 0;
    private uint64 cycles_rcs_total = 0;

    private uint64 cycles_ccs = 0;
    private uint64 cycles_ccs_total = 0;

    private uint64 delta_rcs = 0;
    private uint64 delta_total_rcs = 0;

    private uint64 delta_ccs = 0;
    private uint64 delta_total_ccs = 0;

    public double gpu_percentage { get; private set; }

    private int pid;
    private int update_interval;
    private Gee.ArrayList<GLib.File> drm_files;

    internal string path_fdinfo;
    internal string path_fd;

    public ProcessDRM (int pid, int update_interval) {
        this.pid = pid;
        this.update_interval = update_interval;

        path_fdinfo = "/proc/%d/fdinfo".printf (pid);
        path_fd = "/proc/%d/fd".printf (pid);

        get_drm_files ();
    }

    public ProcessDRM.with_paths (int pid, int update_interval, string path_fdinfo, string path_fd) {
        this.pid = pid;
        this.update_interval = update_interval;
        this.path_fdinfo = path_fdinfo;
        this.path_fd = path_fd;

        get_drm_files ();
    }

    private void get_drm_files () {
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

                bool is_drm = ProcessUtils.is_drm_fd (fd_dir_fd, name);
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

        // Every GPU driver creates a bit different DRM file content,
        // so we need to use a specific gpu percentage calculation functions
        switch (driver) {
        case "i915":
            calculate_percentage_ns (ref engine_render, ref last_engine_render);
            break;
        case "xe":
            calculate_percentage_cycles (ref delta_rcs, ref delta_total_rcs);
            break;
        case "amdgpu":
             calculate_percentage_ns (ref engine_gfx, ref last_engine_gfx);
             break;
        default:
            // Handle default case
            gpu_percentage = -1;
            break;
        }
    }

    private void calculate_percentage_ns (ref uint64 engine, ref uint64 last_engine) {
        if (last_engine != 0) {
            // Since values in the files are in nanoseconds, it is also needed to convert
            // the interval to nanoseconds (10^9)
            gpu_percentage = 100 * ((double) (engine - last_engine)) / (update_interval * 1e9);
        }
        last_engine = engine;
    }

    private void calculate_percentage_cycles (ref uint64 delta, ref uint64 delta_total) {
        var fraction = (float) delta / (float) delta_total;
        gpu_percentage = delta_total > 0 ? 100 * (fraction.clamp (0.0f, 1.0f)) : 0;
    }

    private void update_cycles (string line, ref uint64 last_cycles, ref uint64 delta) {
        var cycles = uint64.parse (line.strip ().split (" ")[0]);
        delta = cycles > last_cycles ? cycles - last_cycles : 0;
        last_cycles = cycles;
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
            update_cycles (splitted_line[1], ref cycles_rcs, ref delta_rcs);
            break;
        case "drm-total-cycles-rcs":
            update_cycles (splitted_line[1], ref cycles_rcs_total, ref delta_total_rcs);
            break;
        default:
            // Ignore other entries
            break;
        }
    }

}
