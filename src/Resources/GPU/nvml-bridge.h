#pragma once

#include <stdbool.h>
#include <stdint.h>

typedef struct MonitorNvmlGpu MonitorNvmlGpu;

typedef struct {
    unsigned int gpu_percent;
    uint64_t mem_used;
    uint64_t mem_total;
    unsigned int temperature_c;
    bool ok_util;
    bool ok_mem;
    bool ok_temp;
} MonitorNvmlSample;

MonitorNvmlGpu* monitor_nvml_gpu_new_from_pci_bus_id(const char* pci_bus_id);
void monitor_nvml_gpu_destroy(MonitorNvmlGpu* gpu);
bool monitor_nvml_gpu_sample(MonitorNvmlGpu* gpu, MonitorNvmlSample* out);
