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

    [CCode (cname = "struct pci_access", destroy_function = "pci_cleanup", has_type_id = false)]
    public struct Access {
        /* Options you can change: */
        uint method;            /* Access method */
        int writeable;          /* Open in read/write mode */
        int buscentric;         /* Bus-centric view of the world */

        char * id_file_name;    /* Name of ID list file (use pci_set_name_list_path()) */
        int free_id_name;       /* Set if id_file_name is malloced */
        int numeric_ids;        /* Enforce PCI_LOOKUP_NUMERIC (>1 => PCI_LOOKUP_MIXED) */

        uint id_lookup_mode;    /* pci_lookup_mode flags which are set automatically */
                                /* Default: PCI_LOOKUP_CACHE */

        int debugging;          /* Turn on debugging messages */

        /* Functions you can override: */
        // void (*error)(char *msg, ...) PCI_PRINTF (1,2) PCI_NONRET;	/* Write error message and quit */
        // void (*warning)(char *msg, ...) PCI_PRINTF (1,2);	/* Write a warning message */
        // void (*debug)(char *msg, ...) PCI_PRINTF (1,2);	/* Write a debugging message */

        Dev * devices;   /* Devices found on this bus */
    }

    /* Initialize PCI access */
    [CCode (cname = "pci_alloc")]
    Access * pci_alloc ();

    [CCode (cname = "pci_init")]
    void pci_init (Access * acc);

    /* Scanning of devices */
    [CCode (cname = "pci_scan_bus")]
    void pci_scan_bus (Access * acc);

    [CCode (cname = "pci_methods")]
    public struct Methods {}

    [CCode (cname = "pci_property")]
    public struct Property {}


    [CCode (cname = "struct pci_dev", has_type_id = false)]
    public struct Dev {
        Dev * next; /* Next device in the chain */
        uint16 domain_16; /* 16-bit version of the PCI domain for backward compatibility */
        /* 0xffff if the real domain doesn't fit in 16 bits */
        uint8 bus;
        uint8 dev;
        uint8 func; /* Bus inside domain, device and function */

        /* These fields are set by pci_fill_info() */
        uint known_fields; /* Set of info fields already known (see pci_fill_info()) */
        uint16 vendor_id;
        uint16 device_id; /* Identity of the device */
        uint16 device_class; /* PCI device class */
        int irq; /* IRQ number */
        PciAddr base_addr[6]; /* Base addresses including flags in lower bits */
        PciAddr size[6]; /* Region sizes */
        PciAddr rom_base_addr; /* Expansion ROM base address */
        PciAddr rom_size; /* Expansion ROM size */
        Cap * first_cap; /* List of capabilities */
        char * phy_slot; /* Physical slot */
        char * module_alias; /* Linux kernel module alias */
        char * label; /* Device name as exported by BIOS */
        int numa_node; /* NUMA node */
        PciAddr flags[6]; /* PCI_IORESOURCE_* flags for regions */
        PciAddr rom_flags; /* PCI_IORESOURCE_* flags for expansion ROM */
        int domain; /* PCI domain (host bridge) */

        /* Fields used internally */
        Access * access;
        Methods * methods;
        uint8 * cache; /* Cached config registers */
        int cache_len;
        int hdrtype; /* Cached low 7 bits of header type, -1 if unknown */
        void * aux; /* Auxiliary data for use by the back-end */
        Property * properties; /* A linked list of extra properties */
        Cap * last_cap; /* Last capability in the list */
    }

}
