// Read more: https://docs.docker.com/config/containers/runmetrics/

public struct Monitor.CgroupMemoryStat {
    public uint64 cache;
    public uint64 rss;
    public uint64 rss_huge;
    public uint64 shmem;
    public uint64 mapped_file;
    public uint64 dirty;
    public uint64 writeback;
    public uint64 swap;
    public uint64 pgpgin;
    public uint64 pgpgout;
    public uint64 pgfault;
    public uint64 pgmajfault;
    public uint64 inactive_anon;
    public uint64 active_anon;
    public uint64 inactive_file;
    public uint64 active_file;
    public uint64 unevictable;
    public uint64 hierarchical_memory_limit;
    public uint64 hierarchical_memsw_limit;
    public uint64 total_cache;
    public uint64 total_rss;
    public uint64 total_rss_huge;
    public uint64 total_shmem;
    public uint64 total_mapped_file;
    public uint64 total_dirty;
    public uint64 total_writeback;
    public uint64 total_swap;
    public uint64 total_pgpgin;
    public uint64 total_pgpgout;
    public uint64 total_pgfault;
    public uint64 total_pgmajfault;
    public uint64 total_inactive_anon;
    public uint64 total_active_anon;
    public uint64 total_inactive_file;
    public uint64 total_active_file;
    public uint64 total_unevictable;
}
