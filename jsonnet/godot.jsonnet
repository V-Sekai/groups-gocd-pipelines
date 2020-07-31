
local osx_template_extra_commands = [
      {
        type: 'exec',
        arguments: [
          '-c',
          'rm -rf ./bin/osx_template.app',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'cp -r ./misc/dist/osx_template.app ./bin/',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'mkdir -p ./bin/osx_template.app/Contents/MacOS',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'cp ./bin/godot.osx.opt.debug.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'cp ./bin/godot.osx.opt.debug.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
        ],
        command: '/bin/bash',
        working_directory: 'g',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'rm -rf osx.zip',
        ],
        command: '/bin/bash',
        working_directory: 'g/bin',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'zip -9 -r osx.zip osx_template.app/',
        ],
        command: '/bin/bash',
        working_directory: 'g/bin',
      },
      {
        type: 'exec',
        arguments: [
          '-c',
          'rm -rf Godot.app && cp -r ./g/misc/dist/osx_template.app Godot.app',
        ],
        command: '/bin/bash',
      },
    ];


local platform_info_dict = {
  "windows": {
    platform_name: "windows",
    scons_env: "",
    intermediate_godot_binary: "godot.windows.opt.tools.64.exe",
    editor_godot_binary: "godot.windows.opt.tools.64.exe",
    template_debug_binary: "windows_64_debug.exe",
    template_release_binary: "windows_64_release.exe",
    export_directory: "export_windows",
    scons_platform: "windows",
    strip_command: "mingw-strip --strip-debug",
    godot_scons_arguments: "use_llvm=no use_lld=yes",
    extra_tasks: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: null,
  },
  "linux": {
    platform_name: "linux",
    scons_env: "",
    intermediate_godot_binary: "godot.x11.opt.tools.64.llvm",
    editor_godot_binary: "godot.x11.opt.tools.64.llvm",
    template_debug_binary: "linux_x11_64_debug",
    template_release_binary: "linux_x11_64_release",
    export_directory: "export_linux_x11",
    scons_platform: "x11",
    strip_command: "strip --strip-debug",
    godot_scons_arguments: "use_llvm=yes builtin_freetype=yes",
    extra_tasks: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: null,
  },
  "server": {
    platform_name: "server",
    scons_env: "",
    intermediate_godot_binary: "godot_server.x11.opt.tools.64",
    editor_godot_binary: "godot_server.x11.opt.tools.64",
    template_debug_binary: "server_64_debug",
    template_release_binary: "server_64_release",
    export_directory: "export_linux_server",
    scons_platform: "server",
    strip_command: "strip --strip-debug",
    godot_scons_arguments: "", # FIXME: use_llvm=yes????
    extra_tasks: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: null,
  },
  "web": {
    platform_name: "web",
    scons_env: "",
    intermediate_godot_binary: "godot.javascript.opt.debug.zip",
    editor_godot_binary: null,
    template_debug_binary: "webassembly_debug.zip",
    template_release_binary: "webassembly_release.zip",
    strip_command: null, # unknown if release should be built separately.
    scons_platform: "javascript",
    godot_scons_arguments: "use_llvm=yes builtin_freetype=yes",
    extra_tasks: ["/opt/emsdk/emsdk activate latest"],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: null,
  },
  "osx": {
    platform_name: "osx",
    scons_env: "OSXCROSS_ROOT=/opt/osxcross",
    intermediate_godot_binary: "godot.osx.opt.tools.64",
    editor_godot_binary: "Godot",
    template_debug_binary: "godot.osx.opt.debug.64", # FIXME
    template_release_binary: "godot.osx.opt.debug.64", # FIXME
    scons_platform: "osx",
    strip_command: null,
    # FIXME: We should look into using osx_tools.app instead of osx_template.app, because we build with tools=yes
    godot_scons_arguments: "osxcross_sdk=darwin19 CXXFLAGS=\"-Wno-deprecated-declarations -Wno-error \" builtin_freetype=yes",
    extra_tasks: [],
    environment_variables: [
      {
        name: 'PATH',
        value: '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      },
    ],
    template_artifacts_override: [
      {
        type: 'build',
        source: 'g/bin/osx.zip',
        destination: '',
      },
      {
        type: 'build',
        source: 'Godot.app',
        destination: '',
      },
      {
        type: 'build',
        source: 'g/bin/version.txt',
        destination: '',
      },
    ],
    template_output_artifacts: ['osx.zip'],
    template_extra_commands: osx_template_extra_commands,
  },
};

local enabled_engine_platforms = [platform_info_dict[x] for x in ["windows", "linux", "server"]];

local enabled_template_platforms = [platform_info_dict[x] for x in ["windows", "linux", "server"]];


# TODO: Use std.escapeStringBash in case export configurations wish to output executables with spaces.
local groups_export_configurations = {
  "windows": {
    export_name: "windows",
    platform_name: "windows",
    export_configuration: "Windows Desktop",
    export_directory: "export_windows",
    export_executable: "v_sekai_windows.exe",
    itchio_out: "windows-master",
    extra_commands: [
      {
        type: 'exec',
        arguments: [
          '-c',
          'cp -a g/addons/vr_manager/openvr/actions export_windows/',
        ],
        command: '/bin/bash',
        working_directory: '',
      },
    ],
  },
  "linuxDesktop": {
    export_name: "linuxDesktop",
    platform_name: "linux",
    export_configuration: "Linux/X11",
    export_directory: "export_linux_x11",
    export_executable: "v_sekai_linux_x11",
    itchio_out: "x11-master",
    extra_commands: [
      {
        type: 'exec',
        arguments: [
          '-c',
          'cp -a g/addons/vr_manager/openvr/actions export_linux_x11/',
        ],
        command: '/bin/bash',
        working_directory: '',
      },
    ],
  },
  "linuxServer": {
    export_name: "linuxServer",
    platform_name: "server",
    export_configuration: "Linux/Server",
    export_directory: "export_linux_server",
    export_executable: "v_sekai_linux_server",
    itchio_out: "server-master",
    extra_commands: [
      {
        type: 'exec',
        arguments: [
          '-c',
          'rm -f export_linux_server/*.so',
        ],
        command: '/bin/bash',
        working_directory: '',
      }
    ],
  },
};

local enabled_groups_export_platforms = [groups_export_configurations[x] for x in ["windows", "linuxDesktop", "linuxServer"]];


local godot_pipeline(pipeline_name='',
                     godot_status='',
                     godot_git='',
                     godot_branch='',
                     gocd_group='',
                     godot_modules_git='',
                     godot_modules_branch='') = {
  name: pipeline_name,
  group: gocd_group,
  label_template: godot_status + '.${godot_sandbox[:8]}.${COUNT}',
  environment_variables:
    [{
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
#    {
#      name: 'butler_git_sandbox',
#      url: gocd_build_git,
#      type: 'git',
#      branch: gocd_build_branch,
#      destination: 'b',
#    },
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
    {
      name: 'defaultStage',
      clean_workspace: false,
      jobs: [
        {
          name: platform_info["platform_name"] + 'Job',
          resources: [
            'mingw5',
            'linux',
          ],
          artifacts: [
            {
              source: 'g/bin/' + platform_info['editor_godot_binary'],
              destination: '',
              type: 'build',
            },
          ],
          environment_variables: platform_info["environment_variables"],
          tasks: [
            {
              type: 'exec',
              arguments: [
                '-c',
                'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                platform_info["scons_env"] + 'scons werror=no platform=' + platform_info["scons_platform"] + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info["godot_scons_arguments"] +
                if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            if platform_info['editor_godot_binary'] != platform_info['intermediate_godot_binary'] then
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp g/bin/' + platform_info['intermediate_godot_binary'] + 'g/bin/' + platform_info['editor_godot_binary'],
                ],
                command: '/bin/bash',
              }
            else null,
          ],
        } for platform_info in enabled_engine_platforms
      ],
    },
    {
      name: 'templateStage',
      jobs: [
        {
          name: platform_info["platform_name"] + 'Job',
          resources: [
            'linux',
            'mingw5',
          ],
          artifacts: if platform_info["template_artifacts_override"] != null then platform_info["template_artifacts_override"] else [
            {
              type: 'build',
              source: 'g/bin/' + platform_info["template_debug_binary"],
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/' + platform_info["template_release_binary"],
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/version.txt',
              destination: '',
            },
          ],
          environment_variables: platform_info["environment_variables"],
          tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_task,
                ],
                command: '/bin/bash',
                working_directory: 'g',
              } for extra_task in platform_info["extra_tasks"]
            ] + [
            {
              type: 'exec',
              arguments: [
                '-c',
                'sed -i "/^status =/s/=.*/= \\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\"/" version.py',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                platform_info["scons_env"] + 'scons werror=no platform=' + platform_info["scons_platform"] + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info["godot_scons_arguments"] + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'cp bin/' + platform_info["intermediate_godot_binary"] + ' bin/' + platform_info["template_debug_binary"] + ' && cp bin/' + platform_info["intermediate_godot_binary"] + ' bin/' + platform_info["template_release_binary"] + if platform_info["strip_command"] != null then ' && ' + platform_info["strip_command"] + ' bin/' + platform_info["template_release_binary"] else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'eval `sed -e "s/ = /=/" version.py` && echo $major.$minor.$patch.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
          ],
        } for platform_info in enabled_template_platforms
      ],
    },
    {
      name: 'templateZipStage',
      jobs: [
        {
          name: 'defaultJob',
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
              arguments: [
                '-c',
                'rm -rf templates',
              ],
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
              job: enabled_template_platforms[0]["platform_name"] + 'Job',
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
              job: platform_info["platform_name"] + 'Job',
            } for output_artifact in if platform_info["template_output_artifacts"] != null then platform_info["template_output_artifacts"] else [platform_info["template_debug_binary"],
              platform_info["template_release_binary"]]
          ], enabled_template_platforms) + [
            {
              type: 'exec',
              arguments: [
                '-c',
                'rm -rf godot.templates.tpz',
              ],
              command: '/bin/bash',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'zip -9 godot.templates.tpz templates/*',
              ],
              command: '/bin/bash',
            },
          ],
        },
      ],
    },
  ],
};

local generate_godot_gdnative_pipeline(pipeline_name='',
                                  pipeline_dependency='',
                                  gocd_group='',
                                  godot_status='') =
{
  name: pipeline_name,
  group: gocd_group,
  label_template: godot_status + '.${' + pipeline_dependency + '_pipeline_dependency' + '}.${COUNT}',
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
      stage: 'defaultStage',
    },
    {
      name: 'godot-cpp',
      url: 'https://github.com/V-Sekai/godot-cpp.git',
      type: 'git',
      branch: 'groups',
      destination: 'godot-cpp',
      shallow_clone: false,
      ignore_for_scheduling: false,
    },
  ],
  stages: [
    {
      name: 'generateApiJsonStage',
      jobs: [
        {
          name: 'generateApiJsonJob',
          artifacts: [
            {
              type: 'build',
              source: 'api.json',
              destination: '',
            },
          ],
          tasks: [
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              pipeline: pipeline_dependency,
              stage: 'defaultStage',
              job: 'serverJob',
              is_source_a_file: true,
              source: 'godot_server.x11.opt.tools.64',
              destination: '',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                # Due to a godot bug, the server crashes with "pure virtual function called"
                'chmod +x godot_server.x11.opt.tools.64 && HOME="`pwd`" ./godot_server.x11.opt.tools.64 --gdnative-generate-json-api api.json || [[ "$(cat api.json | tail -1)" = "]" ]]',
              ],
              command: '/bin/bash',
              working_directory: '',
            },
          ],
        },
      ],
    },
    {
      name: 'godotCppStage',
      jobs: [
        {
          name: platform_info["platform_name"] + 'Job',
          resources: [
            'linux',
            'mingw5',
          ],
          artifacts: if platform_info["template_artifacts_override"] != null then platform_info["template_artifacts_override"] else [
            {
              type: 'build',
              source: 'godot-cpp/include',
              destination: 'godot-cpp',
            },
            {
              type: 'build',
              source: 'godot-cpp/godot_headers',
              destination: 'godot-cpp',
            },
            {
              type: 'build',
              source: 'godot-cpp/bin',
              destination: 'godot-cpp',
            },
          ],
          environment_variables: platform_info["environment_variables"],
          tasks: [
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              pipeline: pipeline_name,
              stage: 'generateApiJsonStage',
              job: 'generateApiJsonJob',
              is_source_a_file: true,
              source: 'api.json',
              destination: '',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                platform_info["scons_env"] + 'scons werror=no platform=' + platform_info["scons_platform"] + ' target=release -j`nproc` use_lto=no deprecated=no generate_bindings=yes custom_api_file=../api.json ' + platform_info["godot_scons_arguments"],
              ],
              command: '/bin/bash',
              working_directory: 'godot-cpp',
            },
          ],
        } for platform_info in enabled_template_platforms
      ],
    },
    // {
    //   name: 'gdnativeBuildStage',
    //   jobs: std.flatMap(function(platform_info) [
    //     {
    //       name: platform_info["platform_name"] + 'Job',
    //       resources: [
    //         'linux',
    //         'mingw5',
    //       ],
    //       artifacts: if platform_info["template_artifacts_override"] != null then platform_info["template_artifacts_override"] else [
    //         {
    //           type: 'build',
    //           source: 'godot-cpp/include',
    //           destination: 'godot-cpp',
    //         },
    //         {
    //           type: 'build',
    //           source: 'godot-cpp/godot_headers',
    //           destination: 'godot-cpp',
    //         },
    //         {
    //           type: 'build',
    //           source: 'godot-cpp/bin',
    //           destination: 'godot-cpp',
    //         },
    //       ],
    //       environment_variables: platform_info["environment_variables"],
    //       tasks: [
    //         {
    //           type: 'fetch',
    //           artifact_origin: 'gocd',
    //           pipeline: pipeline_name,
    //           stage: 'generateApiJsonStage',
    //           job: 'generateApiJsonJob',
    //           is_source_a_file: true,
    //           source: 'api.json',
    //           destination: '',
    //         },https://github.com/godotengine/godot-cpp/
    //         {
    //           type: 'exec',
    //           arguments: [
    //             '-c',
    //             platform_info["scons_env"] + 'scons werror=no platform=' + platform_info["scons_platform"] + ' target=release -j`nproc` use_lto=no deprecated=no generate_bindings=yes custom_api_file=../api.json ' + platform_info["godot_scons_arguments"] + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
    //           ],
    //           command: '/bin/bash',
    //           working_directory: 'godot-cpp',
    //         },
    //       ],
    //     } for platform_info in enabled_template_platforms
    //   ],
    // },
  ],
};

local godot_tools_pipeline_export(pipeline_name='',
                                  pipeline_dependency='',
                                  itchio_login='',
                                  gocd_group='',
                                  godot_status='',
                                  gocd_project_folder='',
                                  groups_git='',
                                  groups_branch='',
                                  gocd_build_project_material=[],
                                  gocd_material_dependencies=[],
                                  enabled_export_platforms=[],
                                  ) =
  {
    name: pipeline_name,
    group: gocd_group,
    label_template: godot_status + '.${' + pipeline_dependency + '_pipeline_dependency' + '}.${COUNT}',
    environment_variables:
      [{
        name: 'GODOT_STATUS',
        value: godot_status,
      }],
    materials: [
      {
        name: 'groups_git_sandbox',
        url: groups_git,
        type: 'git',
        branch: groups_branch,
        destination: 'g',
      },
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
        name: 'exportStage',
        clean_workspace: false,
        fetch_materials: true,
        jobs: [
          {
            name: export_info["export_name"] + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: export_info["export_directory"],
                destination: '',
              },
            ],
            environment_variables:
              [],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'templateZipStage',
                job: 'defaultJob',
                is_source_a_file: true,
                source: 'godot.templates.tpz',
                destination: '',
              },
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: 'serverJob',
                is_source_a_file: true,
                source: 'godot_server.x11.opt.tools.64',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf templates && unzip "godot.templates.tpz" && export VERSION="`cat templates/version.txt`" && export TEMPLATEDIR=".local/share/godot/templates/$VERSION" && export BASEDIR="`pwd`" && rm -rf "$TEMPLATEDIR" && mkdir -p "$TEMPLATEDIR" && cd "$TEMPLATEDIR" && mv "$BASEDIR"/templates/* . && ln server_* "$BASEDIR/templates/"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf ' + export_info["export_directory"] + ' && mkdir ' + export_info["export_directory"] + ' && chmod +x godot_server.x11.opt.tools.64 && HOME="`pwd`" ./godot_server.x11.opt.tools.64 --export "' + export_info["export_configuration"] + '" "`pwd`"/' + export_info["export_directory"] + '/' + export_info["export_executable"] + ' --path g -v',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ] + export_info["extra_commands"],
          } for export_info in enabled_export_platforms
        ],
      },
      {
        name: 'uploadStage',
        clean_workspace: false,
        jobs: [
          {
            name: export_info["export_name"] + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
#            environment_variables:
#              [{
#                name: 'BUTLER_API_KEY',
#                encrypted_value: butler_api_key,
#              },{name: 'ITCHIO_LOGIN', value: ....}],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_name,
                stage: 'exportStage',
                job: export_info["export_name"] + 'Job',
                is_source_a_file: false,
                source: export_info["export_directory"],
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push ' + export_info["export_directory"] + ' $ITCHIO_LOGIN:' + export_info["itchio_out"] + ' --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          } for export_info in enabled_export_platforms
        ],
      },
    ],
  };

local godot_template_groups_editor = 'godot-template-groups';
local godot_gdnative_pipeline = 'godot-gdnative-groups';
local godot_template_groups_export = 'production-groups-release-export';
local godot_template = [godot_template_groups_editor, godot_gdnative_pipeline, godot_template_groups_export];
{
  'env.goenvironment.json': {
    name: 'development',
    pipelines: godot_template,
    environment_variables:
      [],
  },
  'godot_groups_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_groups_editor,
    godot_status='master.groups',
    godot_git='https://github.com/SaracenOne/godot.git',
    godot_branch='groups',
    gocd_group='beta',
#    godot_modules_git='https://github.com/godot-extended-libraries/godot-modules-fire.git',
#    godot_modules_branch='master',
  )),
  'godot_groups_gdnative.gopipeline.json'
  : std.prune(
    generate_godot_gdnative_pipeline(
      pipeline_name=godot_gdnative_pipeline,
      pipeline_dependency=godot_template_groups_editor,
      gocd_group='beta',
      godot_status='master.groups.release'
    )
  ),
  'godot_groups_export.gopipeline.json'
  : std.prune(
    godot_tools_pipeline_export(
      pipeline_name=godot_template_groups_export,
      pipeline_dependency=godot_template_groups_editor,
      groups_git='git@gitlab.com:SaracenOne/groups.git',
      groups_branch='master',
      gocd_group='beta',
      godot_status='master.groups.release',
      gocd_project_folder='groups',
      gocd_build_project_material=[
        {
          name: 'godot_groups_groups',
          url: 'git@gitlab.com:SaracenOne/groups.git',
          type: 'git',
          branch: 'master',
          destination: 'groups',
        },
      ],
      gocd_material_dependencies=[
        // Todo add all the submodules
      ],
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
}
