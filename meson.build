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
vapidir = meson.current_source_dir() / 'vapi/'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

add_project_arguments(['--vapidir', vapidir], language: 'vala')
add_project_arguments([
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
    '-w',
    # '-g',
    # '--save-temps'
], language: 'c')

livechart_proj = subproject('live-chart')
# elementary_stylesheet = subproject('stylesheet')


app_dependencies = [
    dependency('granite', version: '>= 5.2.0'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('gee-0.8'),
    dependency('gio-2.0'),
    dependency('gobject-2.0'),
    dependency('libgtop-2.0'),
    dependency('libwnck-3.0'),
    dependency('libhandy-1', version: '>=0.90.0'),
    dependency('gdk-x11-3.0'),
    dependency('x11'),
    dependency('udisks2'),

    livechart_proj.get_variable('livechart_dep'),

    meson.get_compiler('c').find_library('m', required : false),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('XNVCtrl'),
    meson.get_compiler('c').find_library('X11'),
    meson.get_compiler('vala').find_library('libxnvctrl', dirs: vapidir),
]


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

subdir('src')


# Add in a post install script
meson.add_install_script('meson/post_install.py')

subdir('po')

# shows size of binary
# meson.add_postconf_script('du', '-h', meson.project_name())
