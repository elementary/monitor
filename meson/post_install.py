#!/usr/bin/env python3

import os
import subprocess

schema_dir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share', 'glib-2.0', 'schemas')
icon_cache_dir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share', 'icons', 'hicolor')

if not os.environ.get('DESTDIR'):
    print('Compiling gsettings schemas…')
    subprocess.call(['glib-compile-schemas', schema_dir])

    print('Updating desktop icon cache…')
    subprocess.call(['gtk-update-icon-cache', '-qtf', icon_cache_dir])
