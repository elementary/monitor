[CCode (cheader_filename = "pci/pci.h", cprefix = "pci_", has_type_id = false)]
namespace Pci {

    public const int LIB_VERSION;

    // version 3.13.0
    // [CCode (cname = "int", cprefix = "PCI_ACCESS_", has_type_id = false)]
    // public enum AccessType {
    // AUTO,           /* Autodetection */
    // SYS_BUS_PCI,    /* Linux /sys/bus/pci */
    // PROC_BUS_PCI,   /* Linux /proc/bus/pci */
    // I386_TYPE1,     /* i386 ports, type 1 */
    // I386_TYPE2,     /* i386 ports, type 2 */
    // FBSD_DEVICE,    /* FreeBSD /dev/pci */
    // AIX_DEVICE,     /* /dev/pci0, /dev/bus0, etc. */
    // NBSD_LIBPCI,    /* NetBSD libpci */
    // OBSD_DEVICE,    /* OpenBSD /dev/pci */
    // DUMP,           /* Dump file */
    // DARWIN,         /* Darwin */
    // SYLIXOS_DEVICE, /* SylixOS pci */
    // HURD,           /* GNU/Hurd */
    // WIN32_CFGMGR32, /* Win32 cfgmgr32.dll */
    // WIN32_KLDBG,    /* Win32 kldbgdrv.sys */
    // WIN32_SYSDBG,   /* Win32 NT SysDbg */
    // MMIO_TYPE1,     /* MMIO ports, type 1 */
    // MMIO_TYPE1_EXT, /* MMIO ports, type 1 extended */
    // ECAM,           /* PCIe ECAM via /dev/mem */
    // AOS_EXPANSION,  /* AmigaOS Expansion library */
    // MAX
    // }

    // version 3.10.0
    [CCode (cname = "int", cprefix = "PCI_ACCESS_", has_type_id = false)]
    public enum AccessType {
        AUTO,           /* Autodetection */
        SYS_BUS_PCI,    /* Linux /sys/bus/pci */
        PROC_BUS_PCI,   /* Linux /proc/bus/pci */
        I386_TYPE1,     /* i386 ports, type 1 */
        I386_TYPE2,     /* i386 ports, type 2 */
        FBSD_DEVICE,    /* FreeBSD /dev/pci */
        AIX_DEVICE,     /* /dev/pci0, /dev/bus0, etc. */
        NBSD_LIBPCI,    /* NetBSD libpci */
        OBSD_DEVICE,    /* OpenBSD /dev/pci */
        DUMP,           /* Dump file */
        DARWIN,         /* Darwin */
        SYLIXOS_DEVICE, /* SylixOS pci */
        HURD,           /* GNU/Hurd */
        MAX
    }

    [SimpleType, CCode (cname = "pciaddr_t", has_type_id = false)]
    public struct PciAddr : uint64 {}

    [CCode (cname = "pci_cap", has_type_id = false)]
    public struct Cap {
        Cap * next;
        uint16 id;        /* PCI_CAP_ID_xxx */
        uint16 type;      /* PCI_CAP_xxx */
        uint addr;        /* Position in the config space */
    }

    [CCode (cname = "struct pci_access", free_function = "pci_cleanup", has_type_id = false)]
    [Compact]
    public class Access {
        /* Options you can change: */
        public uint method;            /* Access method */
        public int writeable;          /* Open in read/write mode */
        public int buscentric;         /* Bus-centric view of the world */

        public char * id_file_name;    /* Name of ID list file (use pci_set_name_list_path()) */
        public int free_id_name;       /* Set if id_file_name is malloced */
        public int numeric_ids;        /* Enforce PCI_LOOKUP_NUMERIC (>1 => PCI_LOOKUP_MIXED) */

        public uint id_lookup_mode;    /* pci_lookup_mode flags which are set automatically */
                                /* Default: PCI_LOOKUP_CACHE */

        public int debugging;          /* Turn on debugging messages */

        /* Functions you can override: */
        // void (*error)(char *msg, ...) PCI_PRINTF (1,2) PCI_NONRET; /* Write error message and quit */
        // void (*warning)(char *msg, ...) PCI_PRINTF (1,2); /* Write a warning message */
        // void (*debug)(char *msg, ...) PCI_PRINTF (1,2); /* Write a debugging message */

        public Dev * devices;   /* Devices found on this bus */

            /* Initialize PCI access */
        [CCode (cname = "pci_alloc")]
        public Access ();

        [CCode (cname = "pci_init")]
        public void init ();

        /* Scanning of devices */
        [CCode (cname = "pci_scan_bus")]
        public void scan_bus ();

        [CCode (cname = "pci_lookup_name")]
        public string lookup_name (char[] buf, int flags, ...);
    }

    [CCode (cname = "pci_methods")]
    public struct Methods {}

    [CCode (cname = "pci_property")]
    public struct Property {}


    [CCode (cname = "struct pci_dev", free_function = "pci_free_dev", has_type_id = false)]
    [Compact]
    public class Dev {
        public Dev * next; /* Next device in the chain */
        public uint16 domain_16; /* 16-bit version of the PCI domain for backward compatibility */
        /* 0xffff if the real domain doesn't fit in 16 bits */
        public uint8 bus;
        public uint8 dev;
        public uint8 func; /* Bus inside domain, device and function */

        /* These fields are set by pci_fill_info() */
        public uint known_fields; /* Set of info fields already known (see pci_fill_info()) */
        public uint16 vendor_id;
        public uint16 device_id; /* Identity of the device */
        public uint16 device_class; /* PCI device class */
        public int irq; /* IRQ number */
        public PciAddr base_addr[6]; /* Base addresses including flags in lower bits */
        public PciAddr size[6]; /* Region sizes */
        public PciAddr rom_base_addr; /* Expansion ROM base address */
        public PciAddr rom_size; /* Expansion ROM size */
        public Cap * first_cap; /* List of capabilities */
        public char * phy_slot; /* Physical slot */
        public char * module_alias; /* Linux kernel module alias */
        public char * label; /* Device name as exported by BIOS */
        public int numa_node; /* NUMA node */
        public PciAddr flags[6]; /* PCI_IORESOURCE_* flags for regions */
        public PciAddr rom_flags; /* PCI_IORESOURCE_* flags for expansion ROM */
        public int domain; /* PCI domain (host bridge) */

        /* Fields used internally */
        //  Access * access;
        //  Methods * methods;
        //  uint8 * cache; /* Cached config registers */
        //  int cache_len;
        //  int hdrtype; /* Cached low 7 bits of header type, -1 if unknown */
        //  void * aux; /* Auxiliary data for use by the back-end */
        //  Property * properties; /* A linked list of extra properties */
        //  Cap * last_cap; /* Last capability in the list */

        private Dev ();
    }

    [CCode (cname = "pci_lookup_mode", cprefix = "PCI_LOOKUP_", has_type_id = false)]
    enum LookupMode {
        VENDOR = 1,                /* Vendor name (args: vendorID) */
        DEVICE = 2,                /* Device name (args: vendorID, deviceID) */
        CLASS = 4,                 /* Device class (args: classID) */
        SUBSYSTEM = 8,
        PROGIF = 16,               /* Programming interface (args: classID, prog_if) */
        NUMERIC = 0x10000,         /* Want only formatted numbers; default if access->numeric_ids is set */
        NO_NUMBERS = 0x20000,      /* Return NULL if not found in the database; default is to print numerically */
        MIXED = 0x40000,           /* Include both numbers and names */
        NETWORK = 0x80000,         /* Try to resolve unknown ID's by DNS */
        SKIP_LOCAL = 0x100000,     /* Do not consult local database */
        CACHE = 0x200000,          /* Consult the local cache before using DNS */
        REFRESH_CACHE = 0x400000,  /* Forget all previously cached entries, but still allow updating the cache */
        NO_HWDB = 0x800000,        /* Do not ask udev's hwdb */
      }

      /*
    * Conversion of PCI ID's to names (according to the pci.ids file)
    *
    * Call pci_lookup_name() to identify different types of ID's:
    *
    * VENDOR    (vendorID) -> vendor
    * DEVICE    (vendorID, deviceID) -> device
    * VENDOR | DEVICE   (vendorID, deviceID) -> combined vendor and device
    * SUBSYSTEM | VENDOR  (subvendorID) -> subsystem vendor
    * SUBSYSTEM | DEVICE  (vendorID, deviceID, subvendorID, subdevID) -> subsystem device
    * SUBSYSTEM | VENDOR | DEVICE (vendorID, deviceID, subvendorID, subdevID) -> combined subsystem v+d
    * SUBSYSTEM | ...   (-1, -1, subvendorID, subdevID) -> generic subsystem
    * CLASS    (classID) -> class
    * PROGIF    (classID, progif) -> programming interface
    */


}
