source_indicator_files = [
    'Indicator.vala',
    'Services/DBusClient.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/IndicatorWidget.vala',
    'Widgets/PopoverWidget.vala',

    meson.project_source_root() / 'src' / 'Resources/ResourcesSerialized.vala',
    meson.project_source_root() / 'src' / 'Utils.vala',
]

wingpanel_dep = dependency('wingpanel', version: '>=2.1.0')

indicator_dependencies = [
    wingpanel_dep
]

shared_module(
    'monitor',
    source_indicator_files,
    icons_gresource,
    dependencies: indicator_dependencies,
    install: true,
    install_dir: wingpanel_dep.get_variable('indicatorsdir', pkgconfig_define: ['libdir', libdir])
)
