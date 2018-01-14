
project('com.github.stsdc.monitor', 'vala', 'c', version: '0.3.1')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
    '-include', 'config.h',
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
]

executable(
    meson.project_name(),
    'src/elementarySystemMonitor.vala',
    'src/MainWindow.vala',
    'src/Widgets/ProcessView.vala',
    'src/Widgets/Search.vala',
    'src/Widgets/Statusbar.vala',
    'src/Models/ApplicationProcessModel.vala',
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
    install: true
)
subdir('data')
subdir('po')