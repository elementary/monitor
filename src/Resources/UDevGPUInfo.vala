using GLib;
using GUdev;

public class Monitor.UDevGPUInfo : Object {
    private string vendor_id;
    private string model_name;
    private string driver_name;

    public UDevGPUInfo() {
        const string[] subsystems = { "pci" };
        var client = new Client(subsystems);
        var enumerator = new GUdev.Enumerator(client);
        var devices = enumerator.execute();
       
        foreach(var device in devices) {
            this.vendor_id = device.get_property("ID_VENDOR_FROM_DATABASE");
            this.model_name = device.get_property("ID_MODEL_FROM_DATABASE");
            this.driver_name = device.get_property("DRIVER");       
           
            if(driver_name == "nvidia" || driver_name == "radeon" || driver_name == "geforce" || driver_name == "amd" || driver_name == "intel") {
                break;
            }
        }
    }

    // Метод для вывода сведений о видеокарте
    public void print_gpu_info() {
        if(vendor_id != null && model_name != null) {
            stdout.printf("GPU Vendor ID: %s\n", vendor_id);
            stdout.printf("GPU Model Name: %s\n", model_name);
            stdout.printf("GPU Driver: %s\n", driver_name);
        } else {
            stderr.printf("Не удалось определить GPU.\\n");
        }
    }

    public string get_model_name() {
        return model_name.split("[", 2)[1].replace("]", "");

    }

    public string get_vendor_id() {
        return vendor_id;
    }

    public string get_driver_name() {
        return driver_name;
    }
}
