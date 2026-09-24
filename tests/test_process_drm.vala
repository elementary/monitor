public class Monitor.ProcessUtils {

    public static bool is_drm_fd (int fd_dir_fd, string name) {
        return true;
    }
}

public class Monitor.MockProcessDRM : ProcessDRM {

    public MockProcessDRM (int pid, int update_interval) {
        base (pid, update_interval);
    }

    public MockProcessDRM.with_paths (int pid, int update_interval, string path_fdinfo, string path_fd) {
        base.with_paths (pid, update_interval, path_fdinfo, path_fd);
    }

}


private void test_process_drm () {

    Test.add_func ("/Monitor/Managers/ProcessDRM", () => {

        int pid = 1;
        int update_interval = 2;
        string path_fdinfo = Monitor.TESTASSETSDIR + "fdinfo";
        string path_fd = Monitor.TESTASSETSDIR + "fd";
        var drm = new Monitor.MockProcessDRM.with_paths (pid, update_interval, path_fdinfo, path_fd);

        drm.update ();

        assert (drm.gpu_percentage < 0);
    });
}

void main (string[] args) {

    Test.init (ref args);
    Gtk.init ();

    test_process_drm ();
    Test.run ();
}
