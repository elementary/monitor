/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

namespace Monitor.PCIUtils {
    const int LIBPCI_MAJOR_VER = (Pci.LIB_VERSION & 0xFF0000) >> 16;
    const int LIBPCI_MINOR_VER = (Pci.LIB_VERSION & 0x00FF00) >> 8;
    const int LIBPCI_PATCH_VER = (Pci.LIB_VERSION & 0x0000FF) >> 0;
}
