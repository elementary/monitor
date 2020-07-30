project('com.github.stsdc.monitor', 'vala', 'c', version: '0.8.1')

# these are Meson modules
gnome = import('gnome')
i18n = import('i18n')


# common dirs
prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))
icondir = join_paths(datadir, 'icons', 'hicolor')

livechart_proj = subproject('live-chart')
livechart_dep = livechart_proj.get_variable('livechart_dep')

# and these are project dependencies
glib = dependency('glib-2.0')
granite = dependency('granite', version: '>= 5.2.0')
gtk = dependency('gtk+-3.0')
gee = dependency('gee-0.8')
gio = dependency('gio-2.0')
gobject = dependency('gobject-2.0')
bamf = dependency('libbamf3') # to remove
gtop = dependency('libgtop-2.0')
wnck = dependency('libwnck-3.0')
wingpanel = dependency('wingpanel-2.0')
gdk_x11 = dependency('gdk-x11-3.0')

config_data = configuration_data()
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())

configure_file(output: 'config.h', configuration: config_data)
config_h_dir = include_directories('.')

icons_gresource = gnome.compile_resources(
    'gresource_icons', 'data/icons/icons.indicator.gresource.xml',
    source_dir: 'data/icons',
    c_name: 'as1'
)

css_gresource = gnome.compile_resources(
    'gresource_css', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as2'
)

c_args = [
    '-include', 'config.h',
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
    '-w',
    # '-g',
    # '--save-temps'
]

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

    'src/Views/SystemView/SystemView.vala',
    'src/Views/SystemView/SystemCPUView.vala',
    'src/Views/SystemView/SystemMemoryView.vala',

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
    'src/Widgets/Chart/ProcessChart.vala',


    # Models
    'src/Models/TreeViewModel.vala',

    # Other
    'src/Managers/AppManager.vala',
    'src/Managers/ProcessManager.vala',
    'src/Managers/Process.vala',
    'src/Managers/ProcessStructs.vala',
    'src/Managers/ProcessUtils.vala',

    'src/Services/Shortcuts.vala',
    'src/Services/DBusServer.vala',

    # Resources
    'src/Resources/Resources.vala',
    'src/Resources/ResourcesSerialized.vala',
    'src/Resources/CPU.vala',
    'src/Resources/Core.vala',
    'src/Resources/Memory.vala',
    'src/Resources/Swap.vala',
    c_args: c_args,
    dependencies: [
        glib,
        granite,
        gtk,
        gee,
        gio,
        gobject,
        bamf, # to remove
        gtop,
        wnck,
        gdk_x11,
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

subdir('data')
subdir('po')

# shows size of binary
# meson.add_postconf_script('du', '-h', meson.project_name())
