#include "nvml-bridge.h"

#include <nvml.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct MonitorNvmlGpu {
    nvmlDevice_t handle;
};

static bool monitor_nvml_initialized = false;

static bool
monitor_nvml_init_once(void) {
    if (monitor_nvml_initialized) {
        return true;
    }

    nvmlReturn_t ret = nvmlInit_v2();
    if (ret != NVML_SUCCESS) {
        fprintf(stderr, "NVML init failed: %s\n", nvmlErrorString(ret));
        return false;
    }

    monitor_nvml_initialized = true;
    return true;
}

MonitorNvmlGpu*
monitor_nvml_gpu_new_from_pci_bus_id(const char* pci_bus_id) {
    if (pci_bus_id == NULL || pci_bus_id[0] == '\0') {
        return NULL;
    }

    if (!monitor_nvml_init_once()) {
        return NULL;
    }

    MonitorNvmlGpu* gpu = calloc(1, sizeof(*gpu));
    if (gpu == NULL) {
        return NULL;
    }

    nvmlReturn_t ret = nvmlDeviceGetHandleByPciBusId_v2(pci_bus_id, &gpu->handle);
    if (ret != NVML_SUCCESS) {
        fprintf(stderr, "NVML PCI lookup failed for %s: %s\n", pci_bus_id, nvmlErrorString(ret));
        free(gpu);
        return NULL;
    }

    return gpu;
}

void
monitor_nvml_gpu_destroy(MonitorNvmlGpu* gpu) {
    free(gpu);
}

bool
monitor_nvml_gpu_sample(MonitorNvmlGpu* gpu, MonitorNvmlSample* out) {
    bool any_success = false;

    if (gpu == NULL || out == NULL) {
        return false;
    }

    memset(out, 0, sizeof(*out));

    nvmlUtilization_t util = {0};
    if (nvmlDeviceGetUtilizationRates(gpu->handle, &util) == NVML_SUCCESS) {
        out->gpu_percent = util.gpu;
        out->ok_util = true;
        any_success = true;
    }

    nvmlMemory_t memory = {0};
    if (nvmlDeviceGetMemoryInfo(gpu->handle, &memory) == NVML_SUCCESS) {
        out->mem_used = memory.used;
        out->mem_total = memory.total;
        out->ok_mem = true;
        any_success = true;
    }

    unsigned int temp = 0;
    if (nvmlDeviceGetTemperature(gpu->handle, NVML_TEMPERATURE_GPU, &temp) == NVML_SUCCESS) {
        out->temperature_c = temp;
        out->ok_temp = true;
        any_success = true;
    }

    return any_success;
}
