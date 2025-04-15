[CCode (cheader_filename = "pci/pci.h", cprefix = "pci_", has_type_id = false)]
namespace Pci {

    public const int LIB_VERSION;

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
        WIN32_CFGMGR32, /* Win32 cfgmgr32.dll */
        WIN32_KLDBG,    /* Win32 kldbgdrv.sys */
        WIN32_SYSDBG,   /* Win32 NT SysDbg */
        MMIO_TYPE1,     /* MMIO ports, type 1 */
        MMIO_TYPE1_EXT, /* MMIO ports, type 1 extended */
        //  ECAM,           /* PCIe ECAM via /dev/mem */
        AOS_EXPANSION,  /* AmigaOS Expansion library */
        MAX
    }

    [SimpleType, CCode (cname = "pciaddr_t", has_type_id = false)]
    public struct PciAddr : uint64 { }

    [CCode (cname = "pci_cap", has_type_id = false)]
    public struct Cap {
        Cap *next;
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

        char *id_file_name;     /* Name of ID list file (use pci_set_name_list_path()) */
        int free_id_name;       /* Set if id_file_name is malloced */
        int numeric_ids;        /* Enforce PCI_LOOKUP_NUMERIC (>1 => PCI_LOOKUP_MIXED) */

        uint id_lookup_mode;    /* pci_lookup_mode flags which are set automatically */
                                /* Default: PCI_LOOKUP_CACHE */

        int debugging;          /* Turn on debugging messages */

        /* Functions you can override: */
        // void (*error)(char *msg, ...) PCI_PRINTF (1,2) PCI_NONRET;	/* Write error message and quit */
        // void (*warning)(char *msg, ...) PCI_PRINTF (1,2);	/* Write a warning message */
        // void (*debug)(char *msg, ...) PCI_PRINTF (1,2);	/* Write a debugging message */

        Dev *devices;    /* Devices found on this bus */

        [CCode (cname = "pci_init")]
        public Access ();
      }

        /* Initialize PCI access */
        [CCode (cname = "pci_alloc")]
        Access *pci_alloc ();


      [CCode (cname = "struct pci_dev", has_type_id = false)]
      public struct Dev {
          Dev *next;                 /* Next device in the chain */
          uint16 domain_16;          /* 16-bit version of the PCI domain for backward compatibility */
                                     /* 0xffff if the real domain doesn't fit in 16 bits */

          /* Bus inside domain, device and function */
          uint8 bus;
          uint8 dev;
          uint8 func;

          /* These fields are set by pci_fill_info() */
          uint known_fields;          /* Set of info fields already known (see pci_fill_info()) */

          /* Identity of the device */
          uint16 vendor_id;
          uint16 device_id;

          uint16 device_class;                /* PCI device class */
          int irq;                            /* IRQ number */
          PciAddr base_addr[6];             /* Base addresses including flags in lower bits */
          PciAddr size[6];                  /* Region sizes */
          PciAddr rom_base_addr;            /* Expansion ROM base address */
          PciAddr rom_size;                 /* Expansion ROM size */
          Cap *first_cap;                     /* List of capabilities */
          char *phy_slot;                     /* Physical slot */
          char *module_alias;                 /* Linux kernel module alias */
          char *label;                        /* Device name as exported by BIOS */
          int numa_node;                      /* NUMA node */
          PciAddr flags[6];                 /* PCI_IORESOURCE_* flags for regions */
          PciAddr rom_flags;                /* PCI_IORESOURCE_* flags for expansion ROM */
          int domain;                         /* PCI domain (host bridge) */
          PciAddr bridge_base_addr[4];      /* Bridge base addresses (without flags) */
          PciAddr bridge_size[4];           /* Bridge sizes */
          PciAddr bridge_flags[4];          /* PCI_IORESOURCE_* flags for bridge addresses */

          /* Programming interface for device_class and revision id */
          uint8 prog_if;
          uint8 rev_id;

          /* Subsystem vendor id and subsystem id */
          uint16 subsys_vendor_id;
          uint16 subsys_id;
          Dev *parent;                /* Parent device, does not have to be always accessible */
          int no_config_access;       /* No access to config space for this device */
          uint32 rcd_link_cap;        /* Link Capabilities register for Restricted CXL Devices */
          uint16 rcd_link_status;     /* Link Status register for RCD */
          uint16 rcd_link_ctrl;       /* Link Control register for RCD */
      }

}
