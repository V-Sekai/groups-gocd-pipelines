local file1 = import 'godot-templates.jsonnet';

{
  [file1.generateFileName('godot_v_sekai_editor')]: file1.generate_pipeline(file1.godot_template_groups_editor, 'groups-4.2.0', 'groups-4.2'),
} + {
  [file1.generateFileName('godot_template_groups_export')]
    : std.prune(file1.templates.godot_tools_pipeline_export(
      pipeline_name=file1.godot_template_groups,
      pipeline_dependency=file1.godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=file1.enabled_groups_export_platforms,
    )),
  } + {
  [file1.generateFileName('docker_groups')]
  : std.prune(
    file1.templates.build_docker_server(
      pipeline_name=file1.docker_pipeline,
      pipeline_dependency=file1.godot_template_groups,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='charlie',
      godot_status='docker',
      docker_repo_groups_server='groupsinfra/groups-server',
      server_export_info=file1.groups_export.groups_export_configurations.linux,
    )
  ),
  [file1.generateFileName('docker_gocd_agent')]
  : std.prune(
    file1.templates.simple_docker_job(
      pipeline_name=file1.docker_gocd_agent_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/gocd-agent-centos-8-groups',
      docker_git='https://github.com/V-Sekai/docker-groups.git',
      docker_branch='master',
      docker_dir='gocd-agent-centos-8-groups',
    )
  ),
  [file1.generateFileName('docker_uro')]
  : std.prune(
    file1.templates.simple_docker_job(
      pipeline_name=file1.docker_uro_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/uro',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
} + {
[file1.generateFileName('env_fire')]: std.prune({
    name: 'itch-fire',
    pipelines: file1.itch_fire_template,
}),
}
