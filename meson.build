project('com.github.stsdc.monitor', 'vala', 'c', version: '0.11.0')

# these are Meson modules
gnome = import('gnome')
i18n = import('i18n')
sass = find_program('sassc')

# common dirs
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))
icondir = join_paths(datadir, 'icons', 'hicolor')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')


livechart_proj = subproject('live-chart')
# elementary_stylesheet = subproject('stylesheet')


livechart_dep = livechart_proj.get_variable('livechart_dep')

# and these are project dependencies
glib = dependency('glib-2.0')
granite = dependency('granite', version: '>= 5.2.0')
gtk = dependency('gtk+-3.0')
gee = dependency('gee-0.8')
gio = dependency('gio-2.0')
gobject = dependency('gobject-2.0')
gtop = dependency('libgtop-2.0')
wnck = dependency('libwnck-3.0')
wingpanel = dependency('wingpanel', version: '>=2.1.0')
gdk_x11 = dependency('gdk-x11-3.0')
udisks2 = dependency ('udisks2')
handy = dependency('libhandy-1', version: '>=0.90.0')


config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', meson.project_name())

subdir('data')


icons_gresource = gnome.compile_resources(
    'gresource_icons', 'data/icons/icons.indicator.gresource.xml',
    source_dir: 'data/icons',
    c_name: 'as1'
)

sass_command = [
    sass,
    '@INPUT@',
    '@OUTPUT@'
]

stylesheet_light = custom_target(
    'theme-monitor-light',
    input : './data/stylesheet/monitor-light.scss',
    output : 'monitor-light.css',
    command : sass_command,
    build_by_default: true
)

stylesheet_dark = custom_target(
    'theme-monitor-dark',
    input : './data/stylesheet/monitor-dark.scss',
    output : 'monitor-dark.css',
    command : sass_command,
    build_by_default: true
)

stylesheet_retrofit = custom_target(
    'theme-monitor-retrofit',
    input : './data/stylesheet/monitor-retrofit.scss',
    output : 'monitor-retrofit.css',
    command : sass_command,
    build_by_default: true
)

css_gresource = gnome.compile_resources(
    'gresource_css',
    'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as2',
    dependencies: [stylesheet_dark, stylesheet_light, stylesheet_retrofit],

)

c_args = [
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
    '-w',
    # '-g',
    # '--save-temps'
]

# conf_data = configuration_data()
# conf_data.set('PROJECT_NAME', meson.project_name())
# conf_data.set('GETTEXT_PACKAGE', meson.project_name())
# conf_data.set('GETTEXT_DIR', join_paths(get_option('prefix'), get_option('localedir')))
# conf_data.set('VERSION', meson.project_version())
# conf_data.set('PREFIX', get_option('prefix'))
# conf_data.set('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
# conf_data.set('BINDIR', join_paths(get_option('prefix'), get_option('bindir')))

project_config = vcs_tag(
	input: vcs_tag(
		input: vcs_tag(
			input: configure_file(
				input: 'src/Conf.vala.in',
				output: 'Conf.vala.in.in.in',
				configuration: config_data
			),
			output: 'Conf.vala.in.in',
			command: ['git', 'rev-parse', '--short', 'HEAD'],
			replace_string: '@GIT_COMMIT_SHORT@',
			fallback: ''
		),
		output: 'Conf.vala.in',
		command: ['git', 'rev-parse', 'HEAD'],
		replace_string: '@GIT_COMMIT@',
		fallback: ''
	),
	output: 'Conf.vala',
	command: ['git', 'symbolic-ref', '--short', '-q', 'HEAD'],
	replace_string: '@GIT_BRANCH@',
	fallback: ''
)

executable(
    meson.project_name(),
    icons_gresource,
    css_gresource,
    'src/Monitor.vala',
    'src/MainWindow.vala',
    'src/Utils.vala',

    # Views
    'src/Views/ProcessView/ProcessView.vala',
    'src/Views/ProcessView/ProcessInfoView/ProcessInfoView.vala',
    'src/Views/ProcessView/ProcessTreeView/CPUProcessTreeView.vala',

    'src/Views/PreferencesView/PreferencesView.vala',
    'src/Views/PreferencesView/PreferencesIndicatorPage.vala',
    'src/Views/PreferencesView/PreferencesGeneralPage.vala',

    'src/Views/SystemView/SystemView.vala',
    'src/Views/SystemView/SystemCPUView.vala',
    'src/Views/SystemView/SystemCPUInfoPopover.vala',
    'src/Views/SystemView/SystemMemoryView.vala',
    'src/Views/SystemView/SystemNetworkView.vala',
    'src/Views/SystemView/SystemStorageView.vala',
    'src/Views/SystemView/SystemGPUView.vala',

    # Widgets related only to ProcessInfoView
    'src/Views/ProcessView/ProcessInfoView/Preventor.vala',
    'src/Views/ProcessView/ProcessInfoView/ProcessInfoHeader.vala',
    'src/Views/ProcessView/ProcessInfoView/ProcessInfoCPURAM.vala',
    'src/Views/ProcessView/ProcessInfoView/ProcessInfoIOStats.vala',
    'src/Views/ProcessView/ProcessInfoView/OpenFilesListBox.vala',

    # Widgets
    'src/Widgets/Headerbar/Headerbar.vala',
    'src/Widgets/Headerbar/Search.vala',
    'src/Widgets/Statusbar/Statusbar.vala',
    'src/Widgets/Labels/LabelVertical.vala',
    'src/Widgets/Labels/LabelRoundy.vala',
    'src/Widgets/Labels/LabelH4.vala',
    'src/Widgets/Chart/Chart.vala',
    'src/Widgets/WidgetResource/WidgetResource.vala',

    # Models
    'src/Models/TreeViewModel.vala',

    # Other
    # 'src/Managers/AppManager.vala',
    'src/Managers/ProcessManager.vala',
    'src/Managers/Process.vala',
    'src/Managers/ProcessStructs.vala',
    'src/Managers/ProcessUtils.vala',

    # Services
    'src/Services/Shortcuts.vala',
    'src/Services/DBusServer.vala',
    'src/Services/Appearance.vala',

    # Resources
    'src/Resources/Resources.vala',
    'src/Resources/ResourcesSerialized.vala',
    'src/Resources/CPU.vala',
    'src/Resources/CPUCache.vala',
    'src/Resources/Core.vala',
    'src/Resources/Memory.vala',
    'src/Resources/Swap.vala',
    'src/Resources/TemperatureSensor.vala',
    'src/Resources/Network.vala',
    'src/Resources/Storage.vala',
    'src/Resources/Drive.vala',
    'src/Resources/GPU/IGPU.vala',
    'src/Resources/GPU/GPUAmd.vala',

    'src/Resources/Hwmon/HwmonPathsParser.vala',
    'src/Resources/Hwmon/IHwmonPathsParserInterface.vala',
    'src/Resources/Hwmon/HwmonPathsParserCPU.vala',
    'src/Resources/Hwmon/HwmonPathsParserGPU.vala',
    'src/Resources/Hwmon/HwmonPathsParserIwlwifi.vala',
    'src/Resources/Hwmon/HwmonPathsParserNVMe.vala',
    'src/Resources/Hwmon/HwmonTemperature.vala',
    'src/Resources/Hwmon/HwmonVoltage.vala',
    'src/Resources/Hwmon/HwmonFrequency.vala',
    'src/Resources/Hwmon/HwmonFan.vala',
    'src/Resources/Hwmon/HwmonPWM.vala',
    'src/Resources/Hwmon/HwmonPower.vala',

    project_config,

    c_args: c_args,
    dependencies: [
        glib,
        granite,
        gtk,
        gee,
        gio,
        gobject,
        gtop,
        wnck,
        gdk_x11,
        udisks2,
        handy,
        livechart_dep,
        meson.get_compiler('c').find_library('m', required : false),
        meson.get_compiler('vala').find_library('posix')
    ],
    vala_args: [
        '--vapidir=' + meson.source_root() + '/vapi/',
    ],
    install: true
)

shared_module(
    'monitor',
    'src/Indicator/Indicator.vala',
    'src/Utils.vala',
    'src/Resources/ResourcesSerialized.vala',

    'src/Indicator/Widgets/DisplayWidget.vala',
    'src/Indicator/Widgets/PopoverWidget.vala',
    'src/Indicator/Widgets/IndicatorWidget.vala',

    'src/Indicator/Services/DBusClient.vala',
    # 'src/Widgets/RevealerSwitch.vala',
    icons_gresource,
    c_args: c_args,
    dependencies: [
        glib,
        granite,
        gobject,
        gtk,
        wingpanel
    ],
    install: true,
    install_dir : wingpanel.get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir]),
)

# Add in a post install script
meson.add_install_script('meson/post_install.py')

subdir('po')

# shows size of binary
# meson.add_postconf_script('du', '-h', meson.project_name())
