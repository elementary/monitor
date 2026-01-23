project('io.elementary.monitor', 'vala', 'c', version: '8.0.1', meson_version: '>=0.59')

# these are Meson modules
gnome = import('gnome')
i18n = import('i18n')
sass = find_program('sassc')

# common dirs
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))
icondir = join_paths(datadir, 'icons', 'hicolor')
vapidir = meson.current_source_dir() / 'vapi/'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')

vala_flags = ['--vapidir', vapidir]

if get_option('nvidia').enabled()
    vala_flags += ['--define', 'NVIDIA_SUPPORT']
endif

add_project_arguments(vala_flags, language: 'vala')

# subprojects should be skipped: https://mesonbuild.com/Release-notes-for-0-58-0.html#skip-subprojects-installation
# needs meson 0.58.0
# elementary_stylesheet = subproject('stylesheet')

app_dependencies = [
    dependency('granite-7', version: '>=7.7.0'),
    dependency('glib-2.0'),
    dependency('gtk4'),
    dependency('gee-0.8'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('libgtop-2.0'),
    dependency('libadwaita-1', version: '>=1.0.0'),
    dependency('gtk4-x11'),
    dependency('udisks2'),
    dependency('json-glib-1.0'),
    dependency('flatpak'),

    dependency(
        'livechart-2',
        version: '>= 1.10.0',
        fallback: ['live-chart', 'livechart_dep'],
    ),

    meson.get_compiler('c').find_library('m', required: false),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('X11'),

    # PCI needs lower version limit '>= 3.8.0'
    meson.get_compiler('c').find_library('pci'),
    meson.get_compiler('vala').find_library('pci', dirs: vapidir),

    # Allow building without nvidia libraries because they're not packaged or does not run
    # on some distros due to incompatibility with muslc. Also they're not needed on ARM architecture
    meson.get_compiler('c').find_library('XNVCtrl', required: get_option('nvidia').enabled()),
    meson.get_compiler('vala').find_library('libxnvctrl', dirs: vapidir, required: get_option('nvidia').enabled()),
]

config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', meson.project_name())

subdir('data')

config_data.set('VCS_TAG', '@VCS_TAG@')
project_config = vcs_tag(
    input: configure_file(
        input: 'src/Conf.vala.in',
        output: 'Conf.vala.in',
        configuration: config_data,
    ),
    output: 'Conf.vala',
    command: ['git', 'describe', '--tags', '--dirty'],
)

subdir('src')

gnome.post_install(
    glib_compile_schemas: true,
    update_desktop_database: true
)

subdir('po')
subdir('tests')
