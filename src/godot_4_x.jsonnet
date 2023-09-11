local godot_templates = import 'godot-templates.jsonnet';

{
  [godot_templates.generateFileName('godot_v_sekai_editor')]: godot_templates.generate_pipeline(godot_templates.godot_template_groups_editor, 'groups-4.2.0', 'groups-4.2'),
} + {
  [godot_templates.generateFileName('godot_template_groups_export')]
    : std.prune(godot_templates.templates.godot_tools_pipeline_export(
      pipeline_name=godot_templates.godot_template_groups,
      pipeline_dependency=godot_templates.godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=godot_templates.enabled_groups_export_platforms,
    )),
  } + {
  [godot_templates.generateFileName('docker_groups')]
  : std.prune(
    godot_templates.templates.build_docker_server(
      pipeline_name=godot_templates.docker_pipeline,
      pipeline_dependency=godot_templates.godot_template_groups,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='charlie',
      godot_status='docker',
      docker_repo_groups_server='groupsinfra/groups-server',
      server_export_info=godot_templates.groups_export.groups_export_configurations.linux,
    )
  ),
  [godot_templates.generateFileName('docker_gocd_agent')]
  : std.prune(
    godot_templates.templates.simple_docker_job(
      pipeline_name=godot_templates.docker_gocd_agent_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/gocd-agent-centos-8-groups',
      docker_git='https://github.com/V-Sekai/docker-groups.git',
      docker_branch='master',
      docker_dir='gocd-agent-centos-8-groups',
    )
  ),
  [godot_templates.generateFileName('docker_uro')]
  : std.prune(
    godot_templates.templates.simple_docker_job(
      pipeline_name=godot_templates.docker_uro_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/uro',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
} + {
[godot_templates.generateFileName('env_fire')]: std.prune({
    name: 'itch-fire',
    pipelines: godot_templates.itch_fire_template,
}),
}
