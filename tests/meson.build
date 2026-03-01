test_sources = files(run_command('list-src.sh', check: true).stdout().strip().split('\n'))


test(
    'monitor-statusbar-test', 
    executable('monitor-statusbar-test', test_sources, [
        meson.project_source_root() / 'src/Widgets/Statusbar/Statusbar.vala',
        meson.project_source_root() / 'src/Resources/ResourcesSerialized.vala',
        meson.project_source_root() / 'src/Utils.vala',
        meson.project_source_root() / 'src/Managers/NetworkConnections.vala',
        meson.project_source_root() / 'src/Managers/ProcessStructs.vala'
    ],
    project_config,
    dependencies: app_dependencies),
    suite: 'monitor-gui-headless'
)
