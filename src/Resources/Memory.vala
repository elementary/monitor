namespace Monitor {
    public class Memory : Object {
        public double total = 0;
        public double used = 0;
        public double shared;
        public double buffer;
        public double cached;
        public double locked;

        private GTop.Memory mem;

        public uint used_percentage {
            get {
                return (uint) (Math.round ((used / total) * 100));
            }
        }

        public uint shared_percentage {
            get {
                return (uint) (Math.round ((shared / used) * 100));
            }
        }

        public uint buffer_percentage {
            get {
                return (uint) (Math.round ((buffer / used) * 100));
            }
        }

        public uint cached_percentage {
            get {
                return (uint) (Math.round ((cached / used) * 100));
            }
        }

        public uint locked_percentage {
            get {
                return (uint) (Math.round ((locked / used) * 100));
            }
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
