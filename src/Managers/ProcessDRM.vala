/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessDRM {
    // Time spent busy in nanoseconds by the
    // render engine executing workloads
    public uint64 engine_render { get; private set; }

    public uint engine_gfx { get; private set; }

    public double gpu_percentage { get; private set; }

    private uint64 last_drm_driver_engine_render;

    private int pid;
    private int update_interval;

    public ProcessDRM (int pid, int update_interval) {
        this.pid = pid;
        this.update_interval = update_interval;
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
            if (err is FileError.ACCES) {

            } else {
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
                    // for i915 there is only drm-engine-render to check
                    case "drm-engine-render":
                        this.engine_render = uint64.parse (splitted_line[1].strip ().split (" ")[0]);
                        if (last_drm_driver_engine_render != 0) {
                            gpu_percentage = 100 * ((double) (this.engine_render - last_drm_driver_engine_render)) / (update_interval * 1e9);
                        }
                        last_drm_driver_engine_render = this.engine_render;
                        // debug ("%s %s", this.application_name, gpu_percentage.to_string ());
                        break;
                    default:
                        // warning ("Unknown value in %s", path);
                        break;
                    }
                }
            } catch (Error e) {
                if (e.code != 14) {
                    // if the error is not `no access to file`, because regular user
                    // TODO: remove `magic` number

                    warning ("Can't read process io: '%s' %d", e.message, e.code);
                }
            }
            break;
        }
    }

    // Based on nvtop
    // https://github.com/Syllo/nvtop/blob/4bf5db248d7aa7528f3a1ab7c94f504dff6834e4/src/extract_processinfo_fdinfo.c#L88
    static bool is_drm_fd (int fd_dir_fd, string name) {
        Posix.Stat stat;
        int ret = Posix.fstatat (fd_dir_fd, name, out stat, 0);
        return ret == 0 && (stat.st_mode & Posix.S_IFMT) == Posix.S_IFCHR && Posix.major (stat.st_rdev) == 226;
    }

}