public class Monitor.ProcessFlatpak : Process {
    public ProcessFlatpak (int _pid) {
        base (_pid);
    }
    // Kills the process
    public new bool kill () {
        // Sends a kill signal that cannot be ignored
        if (Posix.kill (stat.pid, Posix.Signal.KILL) == 0) {
            return true;
        }
        return false;
    }

    // Ends the process
    public new bool end () {
        // Sends a terminate signal
        if (Posix.kill (stat.pid, Posix.Signal.TERM) == 0) {
            return true;
        }
        return false;
    }

}
