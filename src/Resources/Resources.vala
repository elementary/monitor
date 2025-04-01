/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
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

        SessionManager session_manager = get_sessman ();
        string gpu_name = session_manager.renderer.down ();

        if (gpu_name.contains ("intel")) {

        } else if (gpu_name.contains ("nvidia") || gpu_name.contains ("geforce")) {
            gpu = new GPUNvidia ();
            gpu.session_manager = session_manager;
        } else if (gpu_name.contains ("amd")) {
            gpu = new GPUAmd ();
            gpu.session_manager = session_manager;
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

    public SessionManager? get_sessman () {
        try {
            SessionManager session_manager = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager"
            );
            debug ("GPU: %s", session_manager.renderer);
            return session_manager;

        } catch (IOError e) {
            warning (e.message);
            return null;
        }
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
