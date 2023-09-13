{
  platform: import '../lib/platform_dict.json',
  groups_export: import '../lib/groups_export.json',

  enabled_engine_platforms: [self.platform.platform_info_dict[x] for x in ['windows', 'linux', 'web']],
  enabled_template_platforms: self.enabled_engine_platforms,

  enabled_groups_engine_platforms: self.enabled_engine_platforms,
  enabled_groups_template_platforms: self.enabled_engine_platforms,
  enabled_groups_export_platforms: [self.groups_export.groups_export_configurations[x] for x in ['windows', 'linux']],

  groups_gdextension: import '../lib/groups_gdextension.json',
  templates: import '../lib/godot_templates.libsonnet',
  godot_editor_export: import '../lib/godot_editor_export.libsonnet',
  godot_pipeline: import '../lib/godot_pipeline.libsonnet',

  HEADLESS_SERVER_EDITOR: 'godot.linuxbsd.editor.double.x86_64.llvm',

  docker_pipeline: 'docker-groups',
  docker_uro_pipeline: 'docker-uro',
  docker_gocd_agent_pipeline: 'docker-gocd-agent-centos-8-groups',
  godot_template_groups_editor: 'godot-groups-editor',
  godot_template_groups: 'groups-export',
  itch_fire_template: [self.docker_pipeline, self.docker_uro_pipeline, self.docker_gocd_agent_pipeline] + [self.godot_template_groups_editor] + [self.godot_template_groups],

  generate_gocd_group: function(pipeline_name) 
    if pipeline_name == self.docker_pipeline then 'charlie'
    else if pipeline_name == self.godot_template_groups_editor || pipeline_name == self.godot_template_groups then 'gamma'
    else 'default',

  generate_pipeline: function(pipeline_name, godot_status, godot_branch) std.prune(self.godot_pipeline.godot_pipeline(
    pipeline_name=pipeline_name,
    godot_status=godot_status,
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch=godot_branch,
    gocd_group=self.generate_gocd_group(pipeline_name),
    godot_engine_platforms=self.enabled_groups_engine_platforms,
    godot_template_platforms=self.enabled_groups_template_platforms
  )),

  generateFileName: function(name) name + '.gopipeline.json',
}
