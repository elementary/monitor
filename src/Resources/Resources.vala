/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public IGPU gpu;
    private HwmonPathParser hwmon_path_parser;

    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();

        string gpu_name = get_gpu_name ();

        if (gpu_name.contains ("intel")) {

        } else if (gpu_name.contains ("nvidia") || gpu_name.contains ("geforce")) {
            gpu = new GPUNvidia ();
        } else if (gpu_name.contains ("amd")) {
            gpu = new GPUAmd ();
            gpu.hwmon_temperatures = hwmon_path_parser.gpu_paths_parser.temperatures;
        } else {
            warning ("GPU: Unknown: %s", gpu_name);
        }

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
                    if (gpu != null) gpu.update ();

            });
            return true;
        });
    }

    private string get_gpu_name () {
        unowned Pci.Dev pci_device;
        Pci.Access pci_access;

        pci_access = new Pci.Access ();
        pci_access.init ();
        pci_access.scan_bus ();

        pci_device = pci_access.devices;
        char namebuf[1024];
        char classbuf[1024];
        while (pci_device != null) {
            pci_device.fill_info (Pci.FILL_IDENT | Pci.FILL_BASES | Pci.FILL_CLASS_EXT | Pci.FILL_LABEL | Pci.FILL_CLASS);
            //  print (" %04x:%02x:%02x.%d\n", pci_device.domain_16, pci_device.bus, pci_device.dev, pci_device.func);

            //  print (" -r%02x", pci_device.rev_id);
            //  print ("%s\n", pci_device.label);

            // 0x300 is VGA-compatible controller
            if (pci_device.device_class==0x300) {
                string name = pci_access.lookup_name (namebuf, Pci.LookupMode.DEVICE, pci_device.vendor_id, pci_device.device_id);
                string d_class = pci_access.lookup_name (classbuf, Pci.LookupMode.CLASS, pci_device.device_class);
                //  print ("%d %s : %s\n", pci_device.device_class, d_class, name);
                return name;
            }
            pci_device = pci_device.next;
        }
        warning ("LibPCI: GPU not detected.");
        return "";
    }


    public ResourcesSerialized serialize () {
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
