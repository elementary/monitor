source_indicator_files = [
    'Indicator.vala',
    'Services/DBusClient.vala',
    'Widgets/DisplayWidget.vala',
    'Widgets/IndicatorWidget.vala',
    'Widgets/PopoverWidget.vala',

    '../Resources/ResourcesSerialized.vala',
    '../Utils.vala',
]

indicator_dependencies = [
    wingpanel_dep
]

shared_module(
    'monitor',
    source_indicator_files,
    icons_gresource,
    dependencies: indicator_dependencies,
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir]),
)
