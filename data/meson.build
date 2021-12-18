icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(icondir, i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(icondir, i + 'x' + i + '@2', 'apps')
    )
endforeach

dbdir = join_paths(datadir, meson.project_name(), 'database')
config_data.set('DBDIR', dbdir)

install_data(
    join_paths('database', 'cpu_bugs.csv'),
    install_dir: dbdir
)

install_data(
    join_paths('database', 'cpu_features.csv'),
    install_dir: dbdir
)

# sass_command = [
#     sass,
#     '@INPUT@',
#     '@OUTPUT@'
# ]

# target_light = custom_target(
#     'theme-monitor-light',
#     input : './stylesheet/monitor-light.scss',
#     output : 'monitor-light.css',
#     command : sass_command,
#     build_by_default: true
# )



# src = join_paths(meson.build_root(), 'data/monitor-dark.css')
# dest = join_paths(meson.source_root(), 'data/monitor-dark.css')
# message('copying @0@ to @1@ ...'.format(src, dest))
# run_command('cp', src, dest)


install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)

i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(datadir, 'applications')
)

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(datadir, 'metainfo')
)


icons_gresource = gnome.compile_resources(
    'gresource_icons', 'icons/icons.indicator.gresource.xml',
    source_dir: 'icons',
    c_name: 'as1'
)

sass_command = [
    sass,
    '@INPUT@',
    '@OUTPUT@'
]

stylesheet_light = custom_target(
    'theme-monitor-light',
    input : './stylesheet/monitor-light.scss',
    output : 'monitor-light.css',
    command : sass_command,
    build_by_default: true
)

stylesheet_dark = custom_target(
    'theme-monitor-dark',
    input : './stylesheet/monitor-dark.scss',
    output : 'monitor-dark.css',
    command : sass_command,
    build_by_default: true
)

stylesheet_retrofit = custom_target(
    'theme-monitor-retrofit',
    input : './stylesheet/monitor-retrofit.scss',
    output : 'monitor-retrofit.css',
    command : sass_command,
    build_by_default: true
)

css_gresource = gnome.compile_resources(
    'gresource_css',
    'css.gresource.xml',
    source_dir: 'stylesheet',
    c_name: 'as2',
    dependencies: [stylesheet_dark, stylesheet_light, stylesheet_retrofit],

)