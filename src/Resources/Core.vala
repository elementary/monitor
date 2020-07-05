namespace Monitor {
    //from Monilet
    public class Core : GLib.Object {
        private float last_total;
        private float last_used;

        private float _percentage_used;

        public int number { get; set; }
        public float percentage_used {
            get { update_percentage_used (); return _percentage_used; }
        }

        public Core (int number) {
            Object (number: number);
            last_used = 0;
            last_total = 0;
        }

        private void update_percentage_used () {
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

            var used = cpu.xcpu_user[number] + cpu.xcpu_nice[number] + cpu.xcpu_sys[number];

            var difference_used = (float) used - last_used;
            var difference_total = (float) cpu.xcpu_total[number] - last_total;
            var pre_percentage = difference_used.abs () / difference_total.abs ();  // calculate the pre percentage

            _percentage_used = pre_percentage * 100;

            last_used = (float) used;
            last_total = (float) cpu.xcpu_total[number];

            //  debug("Core %d: %f%%", number, _percentage_used);
        }
    }
}
