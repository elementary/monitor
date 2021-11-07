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

        public Memory () {
        }

        public void update () {
            GTop.get_mem (out mem);
            total = (double) (mem.total);
            used = (double) mem.user;
            shared = (double) (mem.shared);
            buffer = (double) (mem.buffer);
            cached = (double) (mem.cached);
            locked = (double) (mem.locked);
        }

    }
}
