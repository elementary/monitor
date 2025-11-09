/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This struct holds paths to cpu cache data
// Learn more: https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-devices-system-cpu
public class Monitor.CPUCache {
    // 
    // allocation_policy:
    //  - WriteAllocate:
    //          allocate a memory location to a cache line
    //          on a cache miss because of a write
    //  - ReadAllocate:
    //          allocate a memory location to a cache line
    //          on a cache miss because of a read
    //  - ReadWriteAllocate:
    //          both writeallocate and readallocate
    public string allocation_policy;

    // LEGACY used only on IA64 and is same as write_policy
    public string attributes;

    // the minimum amount of data in bytes that gets
    // transferred from memory to cache
    public string coherency_line_size;

    // the cache hierarchy in the multi-level cache configuration
    public string level;

    // Etotal number of sets in the cache, a set is a
    // collection of cache lines with the same cache index
    public string number_of_sets;

    // number of physical cache line per cache tag
    public string physical_line_partition;

    // the list of logical cpus sharing the cache
    public string shared_cpu_list;

    // logical cpu mask containing the list of cpus sharing
    // the cache
    public string shared_cpu_map;

    // the total cache size in kB
    public string size;

    //  - Instruction: cache that only holds instructions
    //  - Data: cache that only caches data
    //  - Unified: cache that holds both data and instructions
    public string type;

    // degree of freedom in placing a particular block
    // of memory in the cache
    public string ways_of_associativity;

    //  - WriteThrough:
    //      data is written to both the cache line
    //      and to the block in the lower-level memory
    //  - WriteBack:
    //      data is written only to the cache line and
    //      the modified cache line is written to main
    //      memory only when it is replaced
    public string write_policy;
}
