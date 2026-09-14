/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemView : Gtk.Box {
    private Resources resources;

    private SystemCPUView cpu_view;
    private SystemMemoryView memory_view;
    private SystemNetworkView network_view;
    private SystemStorageView storage_view;
    private GLib.List<SystemGPUView> gpu_views = new GLib.List<SystemGPUView> ();

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;
    }

    public SystemView (Resources _resources) {
        resources = _resources;

        cpu_view = new SystemCPUView (resources.cpu);
        memory_view = new SystemMemoryView (resources.memory, resources.swap);
        network_view = new SystemNetworkView (resources.network);
        storage_view = new SystemStorageView (resources.storage);

        var wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = wrapper
        };

        wrapper.append (cpu_view);
        wrapper.append (memory_view);
        wrapper.append (network_view);
        wrapper.append (storage_view);

        foreach (IGPU gpu in resources.gpu_list) {
            if (gpu is GPUIntel || gpu is GPUNvidia) {
                wrapper.append (build_no_support_label (gpu.name));
            } else {
                var gpu_view = new SystemGPUView (gpu);
                gpu_views.append (gpu_view);
                wrapper.append (gpu_view);
            }
        }

        append (scrolled_window);
    }

    public void update () {
        cpu_view.update ();
        memory_view.update ();
        network_view.update ();
        storage_view.update ();
        gpu_views.foreach ((gpu_view) => gpu_view.update ());
    }

    private Granite.HeaderLabel build_no_support_label (string gpu_name) {
        string notification_text = _("The %s GPU was detected, but is not yet supported.").printf (gpu_name);
        return new Granite.HeaderLabel (notification_text) {
            margin_top = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12
        };
    }
}
