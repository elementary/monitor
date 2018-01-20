
project('com.github.stsdc.monitor', 'vala', 'c', version: '0.3.3')

gnome = import('gnome')
i18n = import('i18n')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
    '-include', 'config.h',
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
    '-w'
]

executable(
    meson.project_name(),
    'src/Monitor.vala',
    'src/MainWindow.vala',
    'src/Widgets/OverallView.vala',
    'src/Widgets/Search.vala',
    'src/Widgets/Headerbar.vala',
    'src/Widgets/Statusbar.vala',
    'src/Models/GenericModel.vala',
    'src/Models/ModelHelper.vala',
    'src/Managers/AppManager.vala',
    'src/Managers/ProcessManager.vala',
    'src/Managers/Process.vala',
    'src/Services/Settings.vala',
    'src/Services/Shortcuts.vala',
    'src/Services/Resources.vala',
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('libbamf3'),
        dependency('libbamf3'),
        dependency('libgtop-2.0'),
        dependency('libwnck-3.0'),
        meson.get_compiler('c').find_library('m', required : false),
        meson.get_compiler('vala').find_library('posix')
    ],
    vala_args: [
        '--vapidir=' + meson.source_root() + '/vapi/',
    ],
    install: true
)

# Add in a post install script
meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
