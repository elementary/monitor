source_app_files = [
    'Monitor.vala',
    'MainWindow.vala',
    'Utils.vala',
    'PCIUtils.vala',

    # Views
    'Views/ProcessView/ProcessView.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoView.vala',
    'Views/ProcessView/ProcessTreeView/CPUProcessTreeView.vala',

    'Views/PreferencesView.vala',

    'Views/SystemView/SystemView.vala',
    'Views/SystemView/SystemCPUView.vala',
    'Views/SystemView/SystemCPUInfoPopover.vala',
    'Views/SystemView/SystemMemoryView.vala',
    'Views/SystemView/SystemNetworkView.vala',
    'Views/SystemView/SystemStorageView.vala',
    'Views/SystemView/SystemGPUView.vala',

    # Widgets related only to ProcessInfoView
    'Views/ProcessView/ProcessInfoView/ProcessInfoHeader.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoCPURAM.vala',
    'Views/ProcessView/ProcessInfoView/ProcessInfoIOStats.vala',
    'Views/ProcessView/ProcessInfoView/OpenFilesTreeView.vala',

    # Widgets
    'Widgets/Statusbar/Statusbar.vala',
    'Widgets/Labels/LabelRoundy.vala',
    'Widgets/Chart/Chart.vala',
    'Widgets/WidgetResource/WidgetResource.vala',

    # Models
    'Models/TreeViewModel.vala',
    'Models/OpenFilesTreeViewModel.vala',

    # Other
    # 'Managers/AppManager.vala',
    'Managers/ProcessManager.vala',
    'Managers/Process.vala',
    'Managers/ProcessStructs.vala',
    'Managers/ProcessUtils.vala',

    # Services
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
    'Resources/Network.vala',
    'Resources/Cgroup/Cgroup.vala',
    'Resources/Cgroup/CgroupStructs.vala',

    'Resources/Storage/Storage.vala',
    'Resources/Storage/StorageParser.vala',
    'Resources/Storage/Disk.vala',
    'Resources/Storage/Volume.vala',

    'Resources/GPU/IGPU.vala',
    'Resources/GPU/GPUAmd.vala',
    'Resources/GPU/GPUNvidia.vala',
    'Resources/GPU/GPUIntel.vala',

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

executable(
    meson.project_name(),
    icons_gresource,
    css_gresource,
    source_app_files,
    project_config,
    dependencies: app_dependencies,
    install: true
)

if get_option('indicator-wingpanel').enabled()
    message ('Indicator Wingpanel will be built')
    subdir('Indicator')
endif
