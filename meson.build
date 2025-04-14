project('io.elementary.monitor', 'vala', 'c', version: '0.17.2')

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

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

add_project_arguments(['--vapidir', vapidir], language: 'vala')
add_project_arguments(['-DWNCK_I_KNOW_THIS_IS_UNSTABLE', '-w'], language: 'c')

# subprojects should be skipped: https://mesonbuild.com/Release-notes-for-0-58-0.html#skip-subprojects-installation
# needs meson 0.58.0
# elementary_stylesheet = subproject('stylesheet')

app_dependencies = [
    dependency('granite', version: '>= 5.2.0'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('gee-0.8'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('libgtop-2.0'),
    dependency('libwnck-3.0'),
    dependency('libhandy-1', version: '>=0.90.0'),
    dependency('gdk-x11-3.0'),
    dependency('x11'),
    dependency('udisks2'),
    dependency('json-glib-1.0'),
    dependency('flatpak'),

    # FIXME Bump required version to >= 1.10.0 when GTK 4 porting
    dependency('livechart', version: '< 1.10.0', fallback: ['live-chart', 'livechart_dep']),

    meson.get_compiler('c').find_library('m', required : false),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('XNVCtrl'),
    meson.get_compiler('c').find_library('X11'),
    meson.get_compiler('c').find_library('pci'),
    meson.get_compiler('vala').find_library('pci', dirs: vapidir),
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
    configuration: config_data
  ),
  output: 'Conf.vala',
  command: ['git', 'describe', '--tags', '--dirty']
)

subdir('src')


# Add in a post install script
meson.add_install_script('meson/post_install.py')

subdir('po')
# subdir('tests')
