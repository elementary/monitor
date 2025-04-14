[CCode (cheader_filename = "pci/pci.h", cprefix = "pci_", has_type_id = false)]
namespace Pci {
    [CCode (cname = "pci_access_type", cprefix = "PCI_ACCESS_", has_type_id = false)]
    [Flags]
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
        ECAM,           /* PCIe ECAM via /dev/mem */
        AOS_EXPANSION,  /* AmigaOS Expansion library */
        MAX
    }

}
