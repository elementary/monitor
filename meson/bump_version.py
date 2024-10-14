#!/usr/bin/env python3

'''
Bump all the versionsss!!!
'''

import sys
import datetime

print ('Bumping everything to: ' + sys.argv[1])

def bump_spec():
    SPEC_FILENAME = "../io.elementary.monitor.spec"
    spec_content = ''
    with open(SPEC_FILENAME, 'r') as f_spec:
        print('Reading spec file: ' + SPEC_FILENAME)
        for line in f_spec.readlines():
            if 'Version:' in line:
                line = 'Version: ' + sys.argv[1] + '\n'
            spec_content += line
    
    with open(SPEC_FILENAME, 'w') as f_spec:
        print('Writing spec file: ' + SPEC_FILENAME)
        f_spec.write(spec_content)

def bump_meson():
    MESON_FILENAME = "../meson.build"
    meson_content = ''
    with open(MESON_FILENAME, 'r') as f_meson:
        print('Reading meson file: ' + MESON_FILENAME)
        for line in f_meson.readlines():
            if 'version: ' in line and 'project' in line:
                # line = 'version: "' + sys.argv[1] + '"\n'
                splitted = line.split('version: ')
                line = splitted[0] + "version: '" + sys.argv[1] + "')\n"

            meson_content += line
    
    with open(MESON_FILENAME, 'w') as f_meson:
        print('Writing meson file: ' + MESON_FILENAME)
        f_meson.write(meson_content)

def bump_deb_changelog():
    DEB_CHANGELOG_FILENAME = "../debian/changelog"
    now = datetime.datetime.now()
    deb_changelog_content = f"""io.elementary.monitor ({sys.argv[1]}) jammy; urgency=low\n
  * <NEW FEATURE>\n -- Stanisław Dac <stadac@pm.me>  {now.strftime("%a, %d %b %Y %H:%M:%S %z")} +0000\n\n"""

    with open(DEB_CHANGELOG_FILENAME, 'r+') as f_deb_changelog:
        content = f_deb_changelog.read()
        f_deb_changelog.seek(0)
        print('Writing deb changelog file: ' + DEB_CHANGELOG_FILENAME)
        f_deb_changelog.write(deb_changelog_content + content)

bump_spec()
bump_meson()
bump_deb_changelog()