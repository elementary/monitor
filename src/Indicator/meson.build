gettext_name = meson.project_name() + '-indicator'

gnome = import('gnome')
i18n = import('i18n')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', gettext_name)
configure_file(output: 'config-indicator.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
    '-include', 'config-indicator.h',
    '-w'
]

wingpanel_dep = dependency('wingpanel-2.0')

shared_module(
    'monitor',
    'Indicator.vala',
    # 'src/Services/ColorInterface.vala',
    # 'src/Widgets/PopoverWidget.vala',
    # 'src/Widgets/RevealerSwitch.vala',
    # asresources,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        wingpanel_dep
    ],
    install: true,
    install_dir : '/usr/lib/x86_64-linux-gnu/wingpanel/'
)

# subdir('po')
