test(
    'monitor-statusbar-test',
    executable(
        'monitor-statusbar-test',
        'test_statusbar.vala',
        'runner.vala',
        meson.project_source_root() / 'src/Widgets/Statusbar/Statusbar.vala',
        meson.project_source_root() / 'src/Resources/ResourcesSerialized.vala',
        meson.project_source_root() / 'src/Utils.vala',
        project_config,
        dependencies: app_dependencies,
    ),
    suite: 'monitor-gui-headless',
)

copy_assets = custom_target(
    'copy_test_assets',
    output: 'assets',
    command: ['cp', '-a', meson.current_source_dir() / 'assets/.', '@OUTPUT@/'],
    build_by_default: true,
)

test(
    'test_process_drm',
    executable(
        meson.project_name() + '-tests',
        'test_process_drm.vala',
        meson.project_source_root() / 'src/Managers/ProcessDRM.vala',
        project_config,
        dependencies: app_dependencies,
    ),
    depends: copy_assets
)
