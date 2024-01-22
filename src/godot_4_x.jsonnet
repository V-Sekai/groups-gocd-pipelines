local groups_export = import '../lib/groups_export.json';
local platform = import '../lib/platform_dict.json';
local templates = import '../lib/templates.libsonnet';

local enabled_groups_export_platforms = [groups_export.groups_export_configurations[x] for x in ['windows', 'linux']];
local enabled_engine_template_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web', 'macos']];
local enabled_template_platforms = [platform.platform_info_dict[x] for x in ['windows', 'linux', 'web', 'macos']];

local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
local docker_gocd_agent_pipeline = 'docker-gocd-agent-centos-8-groups';
local godot_template_groups_editor = 'godot-groups-editor';
local godot_template_groups_editor_mac = 'godot-groups-editor-mac';
local godot_template_groups = 'groups-export';
local godot_template_model_explorer = 'model-explorer-export';

local itch_fire_template = [
  docker_pipeline,
  docker_uro_pipeline,
  docker_gocd_agent_pipeline,
  godot_template_groups_editor,
  godot_template_groups_editor_mac,
  godot_template_groups,
  godot_template_model_explorer,
];

{
  local create_timer(timer_spec) = {
    spec: timer_spec,
    only_on_changes: true,
  },
  local create_environment_variables(godot_status) =
    {
      name: 'GODOT_STATUS',
      value: godot_status,
    },

  local create_materials(godot_git, godot_branch, godot_modules_git, godot_modules_branch) = [
    {
      name: 'godot_sandbox',
      url: godot_git,
      type: 'git',
      branch: godot_branch,
      destination: 'g',
    },
    if godot_modules_git != '' then
      {
        name: 'godot_custom_modules',
        url: godot_modules_git,
        type: 'git',
        branch: godot_modules_branch,
        destination: 'godot_custom_modules',
        shallow_clone: false,
      }
    else null,
  ],

  local create_default_stage(godot_engine_platforms, first_stage_approval) = {
    name: 'defaultStage',
    approval: first_stage_approval,
    jobs: [
      {
        name: platform_info.platform_name + '_job',
        resources: ['mingw5', 'linux'],
        artifacts: [
          {
            source: 'g/bin/' + platform_info.editor_godot_binary,
            destination: '',
            type: 'build',
          },
          if std.endsWith(platform_info.editor_godot_binary, '.exe') then {
            source: 'g/bin/' + templates.exe_to_pdb_path(platform_info.editor_godot_binary),
            destination: '',
            type: 'build',
          } else null,
        ],
        environment_variables: platform_info.environment_variables,
        tasks: [
          {
            type: 'exec',
            arguments: ['-c', 'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py'],
            command: '/bin/bash',
            working_directory: 'g',
          },
          {
            type: 'exec',
            arguments: ['-c', platform_info.scons_env +
                              'scons werror=no platform=' +
                              platform_info.scons_platform +
                              ' target=' + platform_info.target +
                              ' use_lto=no ' +
                              platform_info.godot_scons_arguments],
            command: '/bin/bash',
            working_directory: 'g',
          },
          if platform_info.editor_godot_binary != platform_info.intermediate_godot_binary then {
            type: 'exec',
            arguments: ['-c', 'cp -p g/bin/' + platform_info.intermediate_godot_binary + ' g/bin/' + platform_info.editor_godot_binary],
            command: '/bin/bash',
          } else null,
        ],
      }
      for platform_info in godot_engine_platforms
    ],
  },
  local create_template_stage(godot_template_platforms, godot_modules_git, pipeline_name) = {
    name: 'templateStage',
    jobs: [
      {
        name: platform_info.platform_name + '_job',
        resources: ['linux', 'mingw5'],
        artifacts: if platform_info.template_artifacts_override != null then platform_info.template_artifacts_override else [
          {
            type: 'build',
            source: 'g/bin/' + platform_info.template_debug_binary,
            destination: '',
          },
          {
            type: 'build',
            source: 'g/bin/' + platform_info.template_release_binary,
            destination: '',
          },
          {
            type: 'build',
            source: 'g/bin/version.txt',
            destination: '',
          },
        ],
        environment_variables: platform_info.environment_variables,
        tasks: [
          {
            type: 'exec',
            arguments: ['-c', extra_command],
            command: '/bin/bash',
            working_directory: 'g',
          }
          for extra_command in platform_info.extra_commands
        ] + [
          {
            type: 'exec',
            arguments: [
              '-c',
              'sed -i "/^status =/s/=.*/= "$GODOT_STATUS.$GO_PIPELINE_COUNTER"/" version.py',
            ],
            command: '/bin/bash',
            working_directory: 'g',
          },
          if platform_info.editor_godot_binary == platform_info.intermediate_godot_binary then {
            type: 'fetch',
            artifact_origin: 'gocd',
            pipeline: pipeline_name,
            stage: 'defaultStage',
            job: platform_info.platform_name + '_job',
            is_source_a_file: true,
            source: platform_info.intermediate_godot_binary,
            destination: 'g/bin/',
          } else {
            type: 'exec',
            arguments: [
              '-c',
              platform_info.scons_env +
              'scons werror=no platform=' +
              platform_info.scons_platform +
              ' target=' + platform_info.target +
              ' use_lto=no ' +
              platform_info.godot_scons_arguments +
              if godot_modules_git != '' then ' modules_git=' + godot_modules_git else '',
            ],
            command: '/bin/bash',
            working_directory: 'g',
          },
          {
            type: 'exec',
            arguments: ['-c', 'ls'],
            command: '/bin/bash',
            working_directory: 'g',
          },
          {
            type: 'exec',
            arguments: [
              '-c',
              'cp bin/' + platform_info.intermediate_godot_binary +
              ' bin/' + platform_info.template_debug_binary +
              ' && cp bin/' + platform_info.intermediate_godot_binary +
              ' bin/' + platform_info.template_release_binary +
              if platform_info.strip_command != null then ' && ' +
                                                          platform_info.strip_command +
                                                          ' bin/' + platform_info.template_release_binary else '',
            ],
            command: '/bin/bash',
            working_directory: 'g',
          },
          {
            type: 'exec',
            arguments: [
              '-c',
              'eval `sed -e "s/ = /=/" version.py` && declare "_tmp$patch=.$patch"' +
              ' "_tmp0=" "_tmp=_tmp$patch" && echo $major.$minor${!_tmp}.$GODOT_STATUS' +
              '.$GO_PIPELINE_COUNTER > bin/version.txt',
            ],
            command: '/bin/bash',
            working_directory: 'g',
          },
        ] + [
          {
            type: 'exec',
            arguments: ['-c', extra_command],
            command: '/bin/bash',
            working_directory: 'g',
          }
          for extra_command in platform_info.template_extra_commands
        ],
      }
      for platform_info in godot_template_platforms
    ],
  },

  local create_template_zip_stage(godot_template_platforms, templates, pipeline_name) = {
    name: 'templateZipStage',
    jobs: [
      {
        name: 'defaultJob',
        resources: ['linux', 'mingw5'],
        artifacts: [
          {
            type: 'build',
            source: 'godot.templates.tpz',
            destination: '',
          },
        ],
        tasks: [
          {
            type: 'exec',
            arguments: ['-c', 'rm -rf templates'],
            command: '/bin/bash',
          },
          {
            type: 'fetch',
            artifact_origin: 'gocd',
            is_source_a_file: true,
            source: 'version.txt',
            destination: 'templates',
            pipeline: pipeline_name,
            stage: 'templateStage',
            job: godot_template_platforms[0].platform_name + '_job',
          },
          {
            type: 'fetch',
            artifact_origin: 'gocd',
            is_source_a_file: true,
            source: templates.exe_to_pdb_path(platform.platform_info_dict.windows.editor_godot_binary),
            destination: 'templates',
            pipeline: pipeline_name,
            stage: 'defaultStage',
            job: 'windows_job',
          },
        ] + std.flatMap(function(platform_info) [
          {
            type: 'fetch',
            artifact_origin: 'gocd',
            is_source_a_file: true,
            source: output_artifact,
            destination: 'templates',
            pipeline: pipeline_name,
            stage: 'templateStage',
            job: platform_info.platform_name + '_job',
          }
          for output_artifact in if platform_info.template_output_artifacts != null then platform_info.template_output_artifacts else [
            platform_info.template_debug_binary,
            platform_info.template_release_binary,
          ]
        ], godot_template_platforms) + [
          {
            type: 'exec',
            arguments: ['-c', 'rm -rf godot.templates.tpz'],
            command: '/bin/bash',
          },
          {
            type: 'exec',
            arguments: ['-c', 'zip -1 godot.templates.tpz templates/*'],
            command: '/bin/bash',
          },
        ],
      },
    ],
  },
  local godot_pipeline(
    pipeline_name='',
    godot_status='',
    godot_git='',
    godot_branch='',
    gocd_group='',
    godot_modules_git='',
    godot_modules_branch='',
    godot_engine_platforms=enabled_engine_template_platforms,
    godot_template_platforms=enabled_engine_template_platforms,
    first_stage_approval=null,
    timer_spec='* * * * * ?'
  ) = {
    name: pipeline_name,
    group: gocd_group,
    timer: create_timer(timer_spec),
    label_template: godot_status + '.${godot_sandbox[:8]}.${COUNT}',
    environment_variables: [{
      name: 'GODOT_STATUS',
      value: godot_status,
    }],
    materials: [
      {
        name: 'godot_sandbox',
        url: godot_git,
        type: 'git',
        branch: godot_branch,
        destination: 'g',
      },
      if godot_modules_git != '' then
        {
          name: 'godot_custom_modules',
          url: godot_modules_git,
          type: 'git',
          branch: godot_modules_branch,
          destination: 'godot_custom_modules',
          shallow_clone: false,
        }
      else null,
    ],
    stages: [
      create_default_stage(enabled_template_platforms, first_stage_approval),
      create_template_stage(enabled_template_platforms, godot_modules_git, pipeline_name),
      create_template_zip_stage(enabled_template_platforms, templates, pipeline_name),
    ],
  },
  local generatePipeline(pipeline_name, godot_status, godot_branch) = std.prune(
    godot_pipeline(
      pipeline_name=pipeline_name,
      godot_status=godot_status,
      godot_git='https://github.com/V-Sekai/godot.git',
      godot_branch=godot_branch,
      gocd_group='gamma',
      godot_engine_platforms=enabled_engine_template_platforms,
      godot_template_platforms=enabled_engine_template_platforms,
    ),
  ),
  local generatePipelineMac(pipeline_name, godot_status, godot_branch) = std.prune(
    godot_pipeline(
      pipeline_name=pipeline_name + "-macos",
      godot_status=godot_status,
      godot_git='https://github.com/V-Sekai/godot.git',
      godot_branch=godot_branch,
      gocd_group='gamma',
      godot_engine_platforms=['macos'],
      godot_template_platforms=['macos'],
    ),
  ),
  'godot_v_sekai_editor_mac.gopipeline.json': generatePipelineMac(godot_template_groups_editor_mac, 'groups-4.3.0', 'groups-4.3'),
  'godot_v_sekai_editor.gopipeline.json': generatePipeline(godot_template_groups_editor, 'groups-4.3.0', 'groups-4.3'),
  'godot_template_groups_export.gopipeline.json': std.prune(
    templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='https://github.com/V-Sekai/v-sekai-game.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='groups-4.3',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
  'godot_template_model_explorer_export.gopipeline.json': std.prune(
    templates.godot_tools_pipeline_export(
      pipeline_name=godot_template_model_explorer,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='ifiregames/model-explorer-42',
      project_git='https://github.com/V-Sekai/TOOL_model_explorer.git',
      project_branch='main',
      gocd_group='gamma',
      godot_status='model_explorer-4.3',
      gocd_project_folder='model_explorer',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
  'docker_groups.gopipeline.json': std.prune(
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
  'docker_gocd_agent.gopipeline.json': std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_gocd_agent_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/gocd-agent-centos-8-groups',
      docker_git='https://github.com/V-Sekai/docker-groups.git',
      docker_branch='master',
      docker_dir='gocd-agent-centos-8-groups',
    )
  ),
  'docker_uro.gopipeline.json': std.prune(
    templates.simple_docker_job(
      pipeline_name=docker_uro_pipeline,
      gocd_group='charlie',
      docker_repo_variable='groupsinfra/uro',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
  'env.fire.goenvironment.json': std.prune({
    name: 'itch-fire',
    pipelines: itch_fire_template,
  }),
}
