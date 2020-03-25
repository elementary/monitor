namespace Monitor.Utils {
    public struct SystemResources {
        public int cpu_percentage;
        public int memory_percentage;
        public double memory_used;
        public double memory_total;
        public int swap_percentage;
        public double swap_used;
        public double swap_total;
    }

    const string NOT_AVAILABLE = (_("N/A"));
    const string NO_DATA = "\u2014";
}

    /**
     * Static helper class for unit formatting
     * Author: Laurent Callarec @lcallarec
     */
     public class Monitor.Utils.HumanUnitFormatter {
         
         const string[] SIZE_UNITS   = {"B", "KiB", "MiB", "GiB", "TiB"};
         const double KFACTOR = 1024;
 
        /**
         * format a string of bytes to an human readable format with units
         */
         public static string string_bytes_to_human(string bytes) {
             double current_size = double.parse(bytes);
             string current_size_formatted = bytes.to_string() + HumanUnitFormatter.SIZE_UNITS[0];  
 
             for (int i = 0; i<= HumanUnitFormatter.SIZE_UNITS.length; i++) {
                 if (current_size < HumanUnitFormatter.KFACTOR) {
                      return GLib.Math.round(current_size).to_string() + HumanUnitFormatter.SIZE_UNITS[i];
                 }                
                 current_size = current_size / HumanUnitFormatter.KFACTOR;
             }
 
             return current_size_formatted;
         }

         public static string int_bytes_to_human(int bytes) {
            double bytes_double = (double)bytes;
            string units = _ ("B");
    
            // convert to MiB if needed
            if (bytes_double > 1024.0) {
                bytes_double /= 1024.0;
                units = _ ("KiB");
            }
    
            // convert to GiB if needed
            if (bytes_double > 1024.0) {
                bytes_double /= 1024.0;
                units = _ ("MiB");
            }

            return "%.1f %s".printf (bytes_double, units);
         }
     }
