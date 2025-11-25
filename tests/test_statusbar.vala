using Monitor;

private void test_statusbar () {

    Test.add_func ("/Monitor/Widgets/Statusbar/Statusbar#Statusbar", () => {

        var statusbar = new Monitor.Statusbar ();
        ResourcesSerialized sysres = ResourcesSerialized () {
            cpu_percentage = 99,
            cpu_frequency = 1.44,
            cpu_temperature = 34.0,
            memory_percentage = 99,
            memory_used = 2.0,
            memory_total = 4.0,
            swap_percentage = 1,
            swap_used = 0.1,
            swap_total = 1.0,
            network_up = 12,
            network_down = 23,
            gpu_percentage = 20,
            gpu_memory_percentage = 10,
            gpu_temperature = 31.0
        };

        bool update_result = statusbar.update (sysres);

        assert (update_result == true);
    });
}
