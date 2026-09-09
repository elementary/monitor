source_indicator_files = [
    'Indicator.vala',
    'Services/DBusClient.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/IndicatorWidget.vala',
    'Widgets/IndicatorWidgetPercentage.vala',
    'Widgets/IndicatorWidgetTemperature.vala',
    'Widgets/IndicatorWidgetFrequency.vala',
    'Widgets/IndicatorWidgetBandwidth.vala',
    'Widgets/PopoverWidget.vala',

    meson.project_source_root() / 'src' / 'Resources/ResourcesSerialized.vala',
    meson.project_source_root() / 'src' / 'Utils.vala',
]

wingpanel_dep = dependency('wingpanel-9')
gtk_dep = dependency('gtk4', version: '>= 4.12')

indicator_dependencies = [
    wingpanel_dep,
    gtk_dep
]

shared_module(
    'monitor',
    source_indicator_files,
    icons_gresource,
    dependencies: indicator_dependencies,
    install: true,
    install_dir: wingpanel_dep.get_variable('indicatorsdir', pkgconfig_define: ['libdir', libdir])
)
