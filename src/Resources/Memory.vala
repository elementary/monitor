namespace Monitor {

    public class Memory : Object {
        public double total;
        public double used;
        public double shared;
        public double buffer;
        public double cached;
        public double locked;

        private GTop.Memory mem;

        public int percentage {
            get {
                return (int) (Math.round ((used / total) * 100));
            }
        }

        construct {
            total = 0;
            used = 0;
        }

        public Memory () { }

        public void update () {
            GTop.get_mem (out mem);
            total = (mem.total);
            used = (double) (mem.user / 1024 / 1024) / 1000;
            shared = (double) (mem.shared / 1024 / 1024) / 1000;
            buffer = (double) (mem.buffer / 1024 / 1024) / 1000;
            cached = (double) (mem.cached / 1024 / 1024) / 1000;
            locked = (double) (mem.locked / 1024 / 1024) / 1000;
        }
    }
}
