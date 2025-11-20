project('io.elementary.monitor', 'vala', 'c', version: '8.0.0')

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

add_project_arguments(['--vapidir', vapidir], language: 'vala')

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

    meson.get_compiler('c').find_library('XNVCtrl'),
    meson.get_compiler('vala').find_library('libxnvctrl', dirs: vapidir),
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
