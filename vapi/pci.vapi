[CCode (cheader_filename = "pci/pci.h", cprefix = "pci_", has_type_id = false)]
namespace Pci {

    public const int LIB_VERSION;

    // version 3.10.0
    [CCode (cname = "int", cprefix = "PCI_ACCESS_", has_type_id = false)]
    public enum AccessType {
        /** Autodetection */
        AUTO,
        /** Linux /sys/bus/pci */
        SYS_BUS_PCI,
        /** Linux /proc/bus/pci */
        PROC_BUS_PCI,
        /** i386 ports, type 1 */
        I386_TYPE1,
        /** i386 ports, type 2 */
        I386_TYPE2,
        /** FreeBSD /dev/pci */
        FBSD_DEVICE,
        /** /dev/pci0, /dev/bus0, etc. */
        AIX_DEVICE,
        /** NetBSD libpci */
        NBSD_LIBPCI,
        /** OpenBSD /dev/pci */
        OBSD_DEVICE,
        /** Dump file */
        DUMP,
        /** Darwin */
        DARWIN,
        /** SylixOS pci */
        SYLIXOS_DEVICE,
        /** GNU/Hurd */
        HURD,
        MAX
    }

    [SimpleType, CCode (cname = "pciaddr_t", has_type_id = false)]
    public struct PciAddr : uint64 {}

    [CCode (cname = "pci_cap", has_type_id = false)]
    public struct Cap {
        Cap * next;
        /** PCI_CAP_ID_xxx */
        uint16 id;
        /** PCI_CAP_xxx */
        uint16 type;
        /** Position in the config space */
        uint addr;
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

        public Dev devices;   /* Devices found on this bus */

        /* Initialize PCI access */
        [CCode (cname = "pci_alloc")]
        public Access ();

        [CCode (cname = "pci_init")]
        public void init ();

        /* Scanning of devices */
        [CCode (cname = "pci_scan_bus")]
        public void scan_bus ();

        [CCode (cname = "pci_lookup_name")]
        public unowned string ? lookup_name (char[] buf, int flags, ...);

    }

    [CCode (cname = "pci_methods")]
    public struct Methods {}

    [CCode (cname = "pci_property")]
    public struct Property {}


    [CCode (cname = "struct pci_dev", free_function = "pci_free_dev", has_type_id = false)]
    [Compact]
    public class Dev {
        /** Next device in the chain */
        public Dev next;
        /** 16-bit version of the PCI domain for backward compatibility.*/
        public uint16 domain_16;

        /** Bus inside domain */
        public uint8 bus;
        /** Device inside domain */
        public uint8 dev;
        /** Function inside domain */
        public uint8 func;

        /* These fields are set by pci_fill_info() */
        /** Set of info fields already known (see `pci_fill_info()`) */
        public uint known_fields;
        public uint16 vendor_id;
        /** Identity of the device. Use `pci_fill_info()`*/
        public uint16 device_id;
        /** PCI device class. Use `pci_fill_info()` */
        public uint16 device_class;
        /** IRQ number. Use `pci_fill_info()` */
        public int irq;
        /** Base addresses including flags in lower bits. Use `pci_fill_info()` */
        public PciAddr base_addr[6];
        /** Region sizes. Use `pci_fill_info()` */
        public PciAddr size[6];
        /** Expansion ROM base address. Use `pci_fill_info()` */
        public PciAddr rom_base_addr;
        /** Expansion ROM size. Use `pci_fill_info()` */
        public PciAddr rom_size;
        /** List of capabilities. Use `pci_fill_info()` */
        public Cap * first_cap;
        /** Physical slot. Use `pci_fill_info()` */
        public char * phy_slot;
        /** Linux kernel module alias. Use `pci_fill_info()` */
        public char * module_alias;
        /** Device name as exported by BIOS. Use `pci_fill_info()` */
        public char * label;
        /** NUMA node. Use `pci_fill_info()` */
        public int numa_node;
        /** PCI_IORESOURCE_* flags for regions. Use `pci_fill_info()` */
        public PciAddr flags[6];
        /** PCI_IORESOURCE_* flags for expansion ROM. Use `pci_fill_info()` */
        public PciAddr rom_flags;
        /** PCI domain (host bridge). Use `pci_fill_info()` */
        public int domain;

        /** Programming interface for device_class */
        [Version (since = "3.8.0")]
        public uint8 prog_if;

        /** Revision ID */
        [Version (since = "3.8.0")]
        public uint8 rev_id;

        /** Subsystem vendor id */
        [Version (since = "3.8.0")]
        public uint16 subsys_vendor_id;

        /**Subsystem id */
        [Version (since = "3.8.0")]
        public uint16 subsys_id;

        [CCode (cname = "pci_fill_info")]
        public int fill_info (int flags);

        [CCode (cname = "pci_get_string_property")]
        public unowned string ? get_string_property (int flag);

        private Dev ();
    }

/*
 * Most device properties take some effort to obtain, so libpci does not
 * initialize them during default bus scan. Instead, you have to call
 * pci_fill_info() with the proper PCI_FILL_xxx constants OR'ed together.
 *
 * Some properties are stored directly in the pci_dev structure.
 * The remaining ones can be accessed through pci_get_string_property().
 *
 * pci_fill_info() returns the current value of pci_dev->known_fields.
 * This is a bit mask of all fields, which were already obtained during
 * the lifetime of the device. This includes fields which are not supported
 * by the particular device -- in that case, the field is left at its default
 * value, which is 0 for integer fields and NULL for pointers. On the other
 * hand, we never consider known fields unsupported by the current back-end;
 * such fields always contain the default value.
 *
 * XXX: flags and the result should be unsigned, but we do not want to break the ABI.
 */

    public const int FILL_IDENT;
    public const int FILL_IRQ;
    public const int FILL_BASES;
    public const int FILL_ROM_BASE;
    public const int FILL_SIZES;
    public const int FILL_CLASS;
    public const int FILL_CAPS;
    public const int FILL_EXT_CAPS;
    public const int FILL_PHYS_SLOT;
    public const int FILL_MODULE_ALIAS;
    public const int FILL_LABEL;
    public const int FILL_NUMA_NODE;
    public const int FILL_IO_FLAGS;
    public const int FILL_DT_NODE;      /* Device tree node */
    public const int FILL_IOMMU_GROUP;
    public const int FILL_BRIDGE_BASES;
    public const int FILL_RESCAN;
    [Version (since = "3.8.0")]
    public const int FILL_CLASS_EXT;   /* prog_if and rev_id */
    [Version (since = "3.8.0")]
    public const int FILL_SUBSYS;   /* subsys_vendor_id and subsys_id */
    public const int FILL_PARENT;
    public const int FILL_DRIVER;   /* OS driver currently in use (string property) */

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
    [CCode (cname = "pci_lookup_mode", cprefix = "PCI_LOOKUP_", has_type_id = false)]
    [Flags]
    enum LookupMode {
        /** Vendor name (args: vendorID) */
        VENDOR,
        /** Device name (args: vendorID, deviceID) */
        DEVICE,
        /** Device class (args: classID) */
        CLASS,

        SUBSYSTEM,
        /** Programming interface (args: classID, prog_if) */
        PROGIF,
        /** Want only formatted numbers; default if access->numeric_ids is set */
        NUMERIC,
        /** Return NULL if not found in the database; default is to print numerically */
        NO_NUMBERS,
        /** Include both numbers and names */
        MIXED,
        /** Try to resolve unknown ID's by DNS */
        NETWORK,
        /** Do not consult local database */
        SKIP_LOCAL,
        /** Consult the local cache before using DNS */
        CACHE,
        /** Forget all previously cached entries, but still allow updating the cache */
        REFRESH_CACHE,
        /** Do not ask udev's hwdb */
        NO_HWDB,
    }
}
