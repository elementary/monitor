/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public Gee.ArrayList<IGPU> gpu_list = new Gee.ArrayList<IGPU> ();
    private HwmonPathParser hwmon_path_parser;

    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();

        detect_gpu_pci_devices ();

        cpu.temperatures = hwmon_path_parser.cpu_paths_parser.temperatures;

        update ();
    }

    public void update () {
        Timeout.add_seconds (MonitorApp.settings.get_int ("update-time"), () => {
            new Thread<void> ("update-resources", () => {
                cpu.update ();
                memory.update ();
                network.update ();
                storage.update ();
                swap.update ();

                foreach (var gpu in gpu_list) {
                    gpu.update ();
                }
            });
            return true;
        });
    }

    private void detect_gpu_pci_devices () {
        Pci.Access pci_access = new Pci.Access ();

        pci_access.init ();
        pci_access.scan_bus ();

        char namebuf[1024];

        for (unowned Pci.Dev pci_device = pci_access.devices; pci_device != null; pci_device = pci_device.next) {
            pci_device.fill_info (Pci.FILL_IDENT | Pci.FILL_BASES | Pci.FILL_CLASS_EXT | Pci.FILL_LABEL | Pci.FILL_CLASS);
            string name = pci_access.lookup_name (namebuf, Pci.LookupMode.DEVICE, pci_device.vendor_id, pci_device.device_id);

            // Looking for a specific PCI device class
            if (pci_device.device_class == Utils.PCI_CLASS_VGA_CONTROLLER || pci_device.device_class == Utils.PCI_CLASS_3D_CONTROLLER) {
                // print (" %04x:%02x:%02x.%d\n", pci_device.domain_16, pci_device.bus, pci_device.dev, pci_device.func);

                switch (pci_device.vendor_id) {
                case Utils.PCI_VENDOR_ID_INTEL:
                    debug ("PCI device: GPU: Intel %s", name);
                    IGPU gpu = new GPUIntel (pci_access, pci_device);
                    gpu_list.add (gpu);
                    break;

                case Utils.PCI_VENDOR_ID_NVIDIA:
                    debug ("PCI device: GPU: nVidia %s", name);
                    IGPU gpu = new GPUNvidia (pci_access, pci_device);
                    gpu_list.add (gpu);
                    break;

                case Utils.PCI_VENDOR_ID_AMD:
                    debug ("PCI device: GPU: AMD %s", name);
                    IGPU gpu = new GPUAmd (pci_access, pci_device);
                    gpu.hwmon_temperatures = hwmon_path_parser.gpu_paths_parser.temperatures;
                    gpu_list.add (gpu);
                    break;

                default:
                    warning ("GPU: Unknown: 0x%llX : %s", pci_device.vendor_id, name);
                    break;
                }
            } else {
                debug ("PCI device: vendor: 0x%llX class:0x%llX  %s", pci_device.vendor_id, pci_device.device_class, name);
            }
        }
    }

    public ResourcesSerialized serialize () {

        // quick fix; so no need to comment out GPU
        // code for Indicator and Preferences
        IGPU gpu = gpu_list.size > 0 ? gpu_list.first () : null;

        return ResourcesSerialized () {
                   cpu_percentage = cpu.percentage,
                   cpu_frequency = cpu.frequency,
                   cpu_temperature = cpu.temperature_mean,
                   memory_percentage = memory.used_percentage,
                   memory_used = memory.used,
                   memory_total = memory.total,
                   swap_percentage = swap.percentage,
                   swap_used = swap.used,
                   swap_total = swap.total,
                   network_up = network.bytes_out,
                   network_down = network.bytes_in,
                   gpu_percentage = gpu != null ? gpu.percentage : 0,
                   gpu_memory_percentage = gpu != null ? gpu.memory_percentage : 0,
                   gpu_memory_used = gpu != null ? gpu.memory_vram_used : 0,
                   gpu_memory_total = gpu != null ? gpu.memory_vram_total : 0,
                   gpu_temperature = gpu != null ? gpu.temperature : 0
        };
    }

}
