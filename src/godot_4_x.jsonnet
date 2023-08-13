local platform = import '../lib/platform_dict.json';
local groups_export = import '../lib/groups_export.json';

local enabled_engine_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web']];
local enabled_template_platforms = enabled_engine_platforms;

local enabled_groups_engine_platforms = enabled_engine_platforms;
local enabled_groups_template_platforms = enabled_engine_platforms;
local enabled_groups_export_platforms = [groups_export.groups_export_configurations[x] for x in ['windows', 'linux']];

local groups_gdextension = import '../lib/groups_gdextension.json';
local templates = import '../lib/templates.libsonnet';
local functions = import '../lib/functions.libsonnet';

local HEADLESS_SERVER_EDITOR = 'godot.linuxbsd.editor.double.x86_64.llvm';

local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
local docker_gocd_agent_pipeline = 'docker-gocd-agent-centos-8-groups';
local godot_template_groups_editor = 'godot-groups-editor';
local godot_template_groups = 'groups-export';
local itch_fire_template = [docker_pipeline, docker_uro_pipeline, docker_gocd_agent_pipeline] + [godot_template_groups_editor] + [godot_template_groups];

local godot_editor_export(
  pipeline_name='',
  pipeline_dependency='',
  itchio_login='',
  gocd_group='',
  godot_status='',
  gocd_project_folder='',
  enabled_export_platforms=[],
  first_stage_approval=null,
  timer_spec='* * * * * ?',
) = {
    name: pipeline_name,
    group: gocd_group,
    label_template: pipeline_name + '.${COUNT}',
    timer: {
      spec: timer_spec,
      only_on_changes: true,
    },
    environment_variables:
      [{
        name: 'GODOT_STATUS',
        value: godot_status,
      }],
    materials: [
      {
        name: pipeline_dependency + '_pipeline_dependency',
        type: 'dependency',
        pipeline: pipeline_dependency,
        stage: 'templateZipStage',
        ignore_for_scheduling: false,
      },
    ],
    stages: [
      {
        name: 'uploadStage',
        approval: first_stage_approval,
        jobs: [
          {
            name: export_info.export_name + '_job',
            resources: [
              'linux',
              'mingw5',
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + '_job',
                is_source_a_file: true,
                source: export_info.export_executable,
                destination: export_info.export_directory,
              },
              if std.endsWith(export_info.export_executable, '.exe') then {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + '_job',
                is_source_a_file: true,
                source: templates.exe_to_pdb_path(export_info.export_executable),
                destination: export_info.export_directory,
              } else null,
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push ' + export_info.export_directory + ' ' + itchio_login + ':' + export_info.itchio_out + ' --userversion `date +"%Y-%m-%dT%H%M%SZ" --utc`-$GO_PIPELINE_NAME',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          }
          for export_info in enabled_export_platforms
          if export_info.itchio_out != null
        ],
      },
    ],
  };
{
  'env.fire.goenvironment.json': {
    name: 'itch-fire',
    pipelines: itch_fire_template,
    environment_variables:
      [],
  },
  'godot_v_sekai_editor.gopipeline.json'
  : std.prune(functions.godot_pipeline(
    pipeline_name=godot_template_groups_editor,
    godot_status='groups-4.2.0',
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch='groups-4.2',
    gocd_group='gamma',
    godot_modules_git='',
    godot_modules_branch='main',
    godot_engine_platforms=enabled_groups_engine_platforms,
    godot_template_platforms=enabled_groups_template_platforms
  )),
} + {
  'godot_template_groups_export.gopipeline.json'
    : std.prine(templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )),
  } + {
  'godot_template_groups_export.gopipeline.json'
  : std.prune(
    templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.2',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
} + {
  'docker_groups.gopipeline.json'
  : std.prune(
    templates.build_docker_server(
      pipeline_name=docker_pipeline,
      pipeline_dependency=godot_template_groups,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='charlie',
      godot_status='docker',
      docker_repo_groups_server='groupsinfra/groups-server',
      server_export_info=groups_export.groups_export_configurations.linux,
    )
  ),
  'docker_gocd_agent.gopipeline.json'
  : std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_gocd_agent_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/gocd-agent-centos-8-groups',
      docker_git='https://github.com/V-Sekai/docker-groups.git',
      docker_branch='master',
      docker_dir='gocd-agent-centos-8-groups',
    )
  ),
  'docker_uro.gopipeline.json'
  : std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_uro_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/uro',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
}
