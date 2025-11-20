test_sources = files(run_command('list-src.sh', check: true).stdout().strip().split('\n'))


test(
    'monitor-statusbar-test', 
    executable('monitor-statusbar-test', test_sources, [
        meson.source_root() / 'src/Widgets/Statusbar/Statusbar.vala',
        meson.source_root() / 'src/Resources/ResourcesSerialized.vala',
        meson.source_root() / 'src/Utils.vala'
    ],
    project_config,
    dependencies: app_dependencies),
    suite: 'monitor'
)