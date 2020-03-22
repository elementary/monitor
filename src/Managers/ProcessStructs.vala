// For more info look at: http://man7.org/linux/man-pages/man5/proc.5.html

public struct Monitor.ProcessIO {

    // characters read
    public uint64 rchar;

    // characters written
    public uint64 wchar;

    // read syscalls
    public uint64 syscr;

    // write syscalls
    public uint64 syscw;

    // Attempt to count the number of bytes which this process
    // really did cause to be fetched from the storage layer
    public uint64 read_bytes;

    // Attempt to count the number of bytes which this process
    // caused to be sent to the storage layer.
    public uint64 write_bytes;

    public uint64 cancelled_write_bytes;
}

public struct Monitor.ProcessStatus {
    // process ID
    public int pid;

    // The filename of the executable, in parentheses.
    // This is visible whether or not the executable is
    // swapped out.
    public string comm;

    public string state;

    // The PID of the parent of this process.
    public int ppid;

    // The process group ID of the process.
    public int pgrp;

    // The session ID of the process.
    public uint session;

    // The controlling terminal of the process.
    // (The minor device number is contained in 
    // the combination of bits 31 to 20 and 7 to 0;
    // the major device number is in bits 15 to 8.)
    public uint tty_nr;

    // The ID of the foreground process group of the con‐
    // trolling terminal of the process.
    public uint tpgid;

    // The nice value, a value in the
    // range 19 (low priority) to -20 (high priority).
    public int nice;

    public int priority;

    // Number of threads in this process
    public int num_threads;

    // The time the process started after system boot.
    public uint64 starttime;

}