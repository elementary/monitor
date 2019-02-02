namespace Monitor {

    public class Memory : Object {
        public double total;
        public double used;

        private GTop.Memory mem;

        public int percentage {
            get {
                update ();
                return (int) (Math.round((used / total) * 100));
            }
        }

        construct {
            total = 0;
            used = 0;
        }

        public Memory () { }

        private void update () {
            GTop.get_mem (out mem);
    		total = (double) (mem.total / 1024 / 1024) / 1000;
            used = (double) (mem.user / 1024 / 1024) / 1000;
        }
    }
}
