source_app_files = [
    'Monitor.vala',
    'MainWindow.vala',
    'Utils.vala',

    # Views
    'Views/ProcessView/ProcessView.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoView.vala',
    'Views/ProcessView/ProcessTreeView/CPUProcessTreeView.vala',

    'Views/PreferencesView/PreferencesView.vala',
    'Views/PreferencesView/PreferencesIndicatorPage.vala',
    'Views/PreferencesView/PreferencesGeneralPage.vala',

    'Views/SystemView/SystemView.vala',
    'Views/SystemView/SystemCPUView.vala',
    'Views/SystemView/SystemCPUInfoPopover.vala',
    'Views/SystemView/SystemMemoryView.vala',
    'Views/SystemView/SystemNetworkView.vala',
    'Views/SystemView/SystemStorageView.vala',
    'Views/SystemView/SystemGPUView.vala',

    # Widgets related only to ProcessInfoView
    'Views/ProcessView/ProcessInfoView/Preventor.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoHeader.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoCPURAM.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoIOStats.vala',
    'Views/ProcessView/ProcessInfoView/OpenFilesListBox.vala',

    # Widgets
    'Widgets/Headerbar/Headerbar.vala',
    'Widgets/Headerbar/Search.vala',
    'Widgets/Statusbar/Statusbar.vala',
    'Widgets/Labels/LabelVertical.vala',
    'Widgets/Labels/LabelRoundy.vala',
    'Widgets/Labels/LabelH4.vala',
    'Widgets/Chart/Chart.vala',
    'Widgets/WidgetResource/WidgetResource.vala',

    # Models
    'Models/TreeViewModel.vala',

    # Other
    # 'Managers/AppManager.vala',
    'Managers/ProcessManager.vala',
    'Managers/Process.vala',
    'Managers/ProcessStructs.vala',
    'Managers/ProcessUtils.vala',

    # Services
    'Services/Shortcuts.vala',
    'Services/DBusServer.vala',
    'Services/Appearance.vala',

    # Resources
    'Resources/Resources.vala',
    'Resources/ResourcesSerialized.vala',
    'Resources/CPU.vala',
    'Resources/CPUCache.vala',
    'Resources/Core.vala',
    'Resources/Memory.vala',
    'Resources/Swap.vala',
    'Resources/TemperatureSensor.vala',
    'Resources/Network.vala',
    'Resources/Storage.vala',
    'Resources/Drive.vala',

    'Resources/GPU/IGPU.vala',
    'Resources/GPU/GPUAmd.vala',
    'Resources/GPU/GPUNvidia.vala',

    'Resources/Hwmon/HwmonPathsParser.vala',
    'Resources/Hwmon/IHwmonPathsParserInterface.vala',
    'Resources/Hwmon/HwmonPathsParserCPU.vala',
    'Resources/Hwmon/HwmonPathsParserGPU.vala',
    'Resources/Hwmon/HwmonPathsParserIwlwifi.vala',
    'Resources/Hwmon/HwmonPathsParserNVMe.vala',
    'Resources/Hwmon/HwmonTemperature.vala',
    'Resources/Hwmon/HwmonVoltage.vala',
    'Resources/Hwmon/HwmonFrequency.vala',
    'Resources/Hwmon/HwmonFan.vala',
    'Resources/Hwmon/HwmonPWM.vala',
    'Resources/Hwmon/HwmonPower.vala',
]

source_indicator_files = [
    'Indicator/Indicator.vala',
    'Utils.vala',
    'Resources/ResourcesSerialized.vala',

    'Indicator/Widgets/DisplayWidget.vala',
    'Indicator/Widgets/PopoverWidget.vala',
    'Indicator/Widgets/IndicatorWidget.vala',

    'Indicator/Services/DBusClient.vala',
]

executable(
    meson.project_name(),
    icons_gresource,
    css_gresource,

    source_app_files,
    project_config,
    dependencies: app_dependencies,
    install: true
)


wingpanel_dep = dependency('wingpanel', version: '>=2.1.0')
app_dependencies += [wingpanel_dep]
shared_module(
    'monitor',
    source_indicator_files,

    icons_gresource,
    dependencies: app_dependencies,
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir]),
)