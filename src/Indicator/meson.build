source_indicator_files = [
    'Indicator.vala',
    'Services/DBusClient.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/IndicatorWidget.vala',
    'Widgets/IndicatorGroupWidget.vala',
    'Widgets/IndicatorWidgetPercentage.vala',
    'Widgets/IndicatorWidgetTemperature.vala',
    'Widgets/IndicatorWidgetFrequency.vala',
    'Widgets/IndicatorWidgetBandwidth.vala',
    'Widgets/PopoverWidget.vala',

    meson.project_source_root() / 'src' / 'Resources/ResourcesSerialized.vala',
    meson.project_source_root() / 'src' / 'Utils.vala',
]

wingpanel_dep = dependency('wingpanel-9')

indicator_dependencies = [
    wingpanel_dep,
    dependency('gtk4', version: '>= 4.12'),
    dependency('granite-7', version: '>=7.7.0'),
]

shared_module(
    'monitor',
    source_indicator_files,
    icons_gresource,
    dependencies: indicator_dependencies,
    install: true,
    install_dir: wingpanel_dep.get_variable('indicatorsdir', pkgconfig_define: ['libdir', libdir])
)
