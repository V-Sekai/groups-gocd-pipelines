local platform_info_dict_4_x = {
  windows: {
    platform_name: 'windows',
    scons_env: 'PATH=/opt/llvm-mingw/bin:$PATH ',
    intermediate_godot_binary: 'godot.windows.opt.tools.64.exe',
    editor_godot_binary: 'godot.windows.opt.tools.64.exe',
    template_debug_binary: 'windows_64_debug.exe',
    template_release_binary: 'windows_64_release.exe',
    export_directory: 'export_windows',
    scons_platform: 'windows',
    gdnative_platform: 'windows',
    strip_command: 'mingw-strip --strip-debug',
    godot_scons_arguments: "use_mingw=yes use_llvm=yes use_lld=yes use_thinlto=yes LINKFLAGS=-Wl,-pdb= CCFLAGS='-g -gcodeview' debug_symbols=no",
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  linux: {
    platform_name: 'linux',
    scons_env: '',
    intermediate_godot_binary: 'godot.linuxbsd.opt.tools.64.llvm',
    editor_godot_binary: 'godot.linuxbsd.opt.tools.64.llvm',
    template_debug_binary: 'linux_linuxbsd_64_debug',
    template_release_binary: 'linux_linuxbsd_64_release',
    export_directory: 'export_linux_linuxbsd',
    scons_platform: 'linuxbsd',
    gdnative_platform: 'linux',
    strip_command: 'strip --strip-debug',
    godot_scons_arguments: 'use_static_cpp=yes use_llvm=yes builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  web: {
    platform_name: 'web',
    scons_env: 'source /opt/emsdk/emsdk_env.sh && EM_CACHE=/tmp ',
    intermediate_godot_binary: 'godot.javascript.opt.debug.zip',
    editor_godot_binary: null,
    template_debug_binary: 'webassembly_debug.zip',
    template_release_binary: 'webassembly_release.zip',
    strip_command: null,  // unknown if release should be built separately.
    scons_platform: 'javascript',
    gdnative_platform: 'linux', // TODO: We need godot_speech for web.
    godot_scons_arguments: 'use_llvm=yes builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  macos: {
    platform_name: 'macos',
    scons_env: 'OSXCROSS_ROOT="LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross" ',
    intermediate_godot_binary: 'godot.osx.opt.tools.64',
    editor_godot_binary: 'godot.osx.opt.tools.64',
    template_debug_binary: 'godot_osx_debug.64',
    template_release_binary: 'godot_osx_release.64',
    scons_platform: 'osx',
    gdnative_platform: 'osx',
    strip_command: 'LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S',
    // FIXME: We should look into using osx_tools.app instead of osx_template.app, because we build with tools=yes
    godot_scons_arguments: 'osxcross_sdk=darwin19 CXXFLAGS="-Wno-deprecated-declarations -Wno-error " builtin_freetype=yes',
    extra_commands: [],
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
    template_extra_commands: [
      'rm -rf ./bin/osx_template.app',
      'cp -r ./misc/dist/osx_template.app ./bin/',
      'mkdir -p ./bin/osx_template.app/Contents/MacOS',
      'mv ./bin/godot_osx_debug.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
      'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_debug.64',
      'mv ./bin/godot_osx_release.64 ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
      'chmod +x ./bin/osx_template.app/Contents/MacOS/godot_osx_release.64',
      'rm -rf bin/osx.zip',
      'cd bin && zip -9 -r osx.zip osx_template.app/',
      'cd .. && rm -rf Godot.app && cp -r ./g/misc/dist/osx_template.app Godot.app',
    ],
  },
};

local enabled_engine_platforms_4_x = [platform_info_dict_4_x[x] for x in ['windows', 'linux', 'macos']];

local enabled_template_platforms_4_x= [platform_info_dict_4_x[x] for x in ['windows', 'linux', /*'web',*/ 'macos']];

// TODO: Use std.escapeStringBash in case export configurations wish to output executables with spaces.
local groups_export_configurations = {
  windows: {
    export_name: 'windows',
    platform_name: 'windows',
    gdnative_platform: 'windows',
    export_configuration: 'Windows Desktop',
    export_directory: 'export_windows',
    export_executable: 'v_sekai_windows.exe',
    itchio_out: 'windows-master',
    prepare_commands: [
      //'mingw-strip --strip-debug godot_speech/libGodotSpeech.dll',
      'cp -p godot_speech/libGodotSpeech.dll g/addons/godot_speech/bin/',
      //'strip --strip-debug godot_openvr/libgodot_openvr.dll',
      'cp -p godot_openvr/libgodot_openvr.dll godot_openvr/openvr_api.dll g/addons/godot-openvr/bin/win64/',
    ],
    extra_commands: [
      'cp -a g/assets/actions/openvr/actions export_windows/',
      'cp -p pdbs/*.pdb godot_speech/*.pdb godot_openvr/*.pdb export_windows/',
    ],
  },
  linuxDesktop: {
    export_name: 'linuxDesktop',
    platform_name: 'linux',
    gdnative_platform: 'linux',
    export_configuration: 'Linux/X11',
    export_directory: 'export_linux_x11',
    export_executable: 'v_sekai_linux_x11',
    itchio_out: 'x11-master',
    prepare_commands: [
      //'strip --strip-debug godot_speech/libGodotSpeech.so',
      'cp -p godot_speech/libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so',
      //'strip --strip-debug godot_openvr/libgodot_openvr.so',
      'cp -p godot_openvr/libgodot_openvr.so godot_openvr/libopenvr_api.so g/addons/godot-openvr/bin/x11/',
    ],
    extra_commands: [
      'cp -a g/assets/actions/openvr/actions export_linux_x11/',
    ],
  },
  linuxServer: {
    export_name: 'linuxServer',
    platform_name: 'server',
    gdnative_platform: 'linux',
    export_configuration: 'Linux/Server',
    export_directory: 'export_linux_server',
    export_executable: 'v_sekai_linux_server',
    itchio_out: 'server-master',
    prepare_commands: [
      //'strip --strip-debug godot_speech/libGodotSpeech.so',
      'cp -p godot_speech/libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so',
    ],
    extra_commands: [
      'rm -f export_linux_server/*.so',
    ],
  },
  macos: {
    export_name: 'macos',
    platform_name: 'macos',
    gdnative_platform: 'osx',
    export_configuration: 'Mac OSX',
    export_directory: 'export_macos',
    export_executable: 'v_sekai_macos.zip',
    itchio_out: 'macos',
    prepare_commands: [
      'cp -p godot_speech/libGodotSpeech.dylib g/addons/godot_speech/bin/libGodotSpeech.dylib',
      'sed -ibak -e "/mix_rate=48000/d" g/project.godot',
    ],
    extra_commands: [
      // https://itch.io/t/303643/cant-get-a-mac-app-to-run-after-butler-push-resolved
      'cd export_macos && unzip v_sekai_macos.zip && rm v_sekai_macos.zip',
    ],
  },
  web: {
    export_name: 'web',
    platform_name: 'web',
    gdnative_platform: 'linux',
    export_configuration: 'HTML5',
    export_directory: 'export_web',
    export_executable: 'v_sekai_web.html',
    itchio_out: null,
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
};

local enabled_groups_export_platforms_4_x = [groups_export_configurations[x] for x in ['windows', 'linuxDesktop', 'macos']];

local exe_to_pdb_path(binary) = (std.substr(binary, 0, std.length(binary) - 4) + '.pdb');

local godot_pipeline_4_x(pipeline_name='',
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
          name: platform_info.platform_name + 'Job',
          resources: [
            'mingw5',
            'linux',
          ],
          artifacts: [
            {
              source: 'g/bin/' + platform_info.editor_godot_binary,
              destination: '',
              type: 'build',
            },
            if std.endsWith(platform_info.editor_godot_binary, '.exe') then {
              source: 'g/bin/' + exe_to_pdb_path(platform_info.editor_godot_binary),
              destination: '',
              type: 'build',
            } else null,
          ],
          environment_variables: platform_info.environment_variables,
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
                platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments +
                if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            if platform_info.editor_godot_binary != platform_info.intermediate_godot_binary then
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp -p g/bin/' + platform_info.intermediate_godot_binary + 'g/bin/' + platform_info.editor_godot_binary,
                ],
                command: '/bin/bash',
              }
            else null,
          ],
        }
        for platform_info in enabled_engine_platforms_4_x
      ],
    },
    {
      name: 'templateStage',
      jobs: [
        {
          name: platform_info.platform_name + 'Job',
          resources: [
            'linux',
            'mingw5',
          ],
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
              arguments: [
                '-c',
                extra_command,
              ],
              command: '/bin/bash',
              working_directory: 'g',
            }
            for extra_command in platform_info.extra_commands
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
            if platform_info.editor_godot_binary == platform_info.intermediate_godot_binary then {
              type: 'fetch',
              artifact_origin: 'gocd',
              pipeline: pipeline_name,
              stage: 'defaultStage',
              job: platform_info.platform_name + 'Job',
              is_source_a_file: true,
              source: platform_info.intermediate_godot_binary,
              destination: 'g/bin/',
            } else {
              type: 'exec',
              arguments: [
                '-c',
                platform_info.scons_env + 'scons werror=no platform=' + platform_info.scons_platform + ' target=release_debug -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_debug_binary + ' && cp bin/' + platform_info.intermediate_godot_binary + ' bin/' + platform_info.template_release_binary + if platform_info.strip_command != null then ' && ' + platform_info.strip_command + ' bin/' + platform_info.template_release_binary else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'eval `sed -e "s/ = /=/" version.py` && declare "_tmp$patch=.$patch" "_tmp0=" "_tmp=_tmp$patch" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
          ] + [
            {
              type: 'exec',
              arguments: [
                '-c',
                extra_command,
              ],
              command: '/bin/bash',
              working_directory: 'g',
            }
            for extra_command in platform_info.template_extra_commands
          ],
        }
        for platform_info in enabled_template_platforms_4_x
      ],
    },
    {
      name: 'templateZipStage',
      jobs: [
        {
          name: 'defaultJob',
          resources: [
            'linux',
            'mingw5',
          ],
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
              job: enabled_template_platforms_4_x[0].platform_name + 'Job',
            },
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: exe_to_pdb_path(platform_info_dict_4_x.windows.editor_godot_binary),
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'defaultStage',
              job: 'windowsJob',
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
              job: platform_info.platform_name + 'Job',
            }
            for output_artifact in if platform_info.template_output_artifacts != null then platform_info.template_output_artifacts else [
              platform_info.template_debug_binary,
              platform_info.template_release_binary,
            ]
          ], enabled_template_platforms_4_x) + [
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

local godot_editor_export_4_x(
  pipeline_name='',
  pipeline_dependency='',
  itchio_login='',
  gocd_group='',
  godot_status='',
  gocd_project_folder='',
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
            name: export_info.export_name + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: export_info.export_directory,
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
              }
            ] +
            [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf templates && unzip "godot.templates.tpz" && mkdir pdbs && mv templates/*.pdb pdbs && export VERSION="`cat templates/version.txt`" && export TEMPLATEDIR=".local/share/godot/templates/$VERSION" && export BASEDIR="`pwd`" && rm -rf "$TEMPLATEDIR" && mkdir -p "$TEMPLATEDIR" && cd "$TEMPLATEDIR" && mv "$BASEDIR"/templates/* . && ln server_* "$BASEDIR/templates/"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_task,
                ],
                command: '/bin/bash',
                working_directory: '',
              }
              for extra_task in export_info.prepare_commands
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_task,
                ],
                command: '/bin/bash',
                working_directory: '',
              }
              for extra_task in export_info.extra_commands
            ],
          }
          for export_info in enabled_export_platforms
        ],
      },
      {
        name: 'uploadStage',
        clean_workspace: false,
        jobs: [
          {
            name: export_info.export_name + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_name,
                stage: 'exportStage',
                job: export_info.export_name + 'Job',
                is_source_a_file: false,
                source: export_info.export_directory,
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push ' + export_info.export_directory + ' $ITCHIO_LOGIN:' + export_info.itchio_out + ' --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
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

local godot_editor_export(
  pipeline_name='',
  pipeline_dependency='',
  itchio_login='',
  gocd_group='',
  godot_status='',
  gocd_project_folder='',
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
            name: export_info.export_name + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: export_info.export_directory,
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
              }
            ] +
            [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf templates && unzip "godot.templates.tpz" && mkdir pdbs && mv templates/*.pdb pdbs && export VERSION="`cat templates/version.txt`" && export TEMPLATEDIR=".local/share/godot/templates/$VERSION" && export BASEDIR="`pwd`" && rm -rf "$TEMPLATEDIR" && mkdir -p "$TEMPLATEDIR" && cd "$TEMPLATEDIR" && mv "$BASEDIR"/templates/* . && ln server_* "$BASEDIR/templates/"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_task,
                ],
                command: '/bin/bash',
                working_directory: '',
              }
              for extra_task in export_info.prepare_commands
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_task,
                ],
                command: '/bin/bash',
                working_directory: '',
              }
              for extra_task in export_info.extra_commands
            ],
          }
          for export_info in enabled_export_platforms
        ],
      },
      {
        name: 'uploadStage',
        clean_workspace: false,
        jobs: [
          {
            name: export_info.export_name + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_name,
                stage: 'exportStage',
                job: export_info.export_name + 'Job',
                is_source_a_file: false,
                source: export_info.export_directory,
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push ' + export_info.export_directory + ' $ITCHIO_LOGIN:' + export_info.itchio_out + ' --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
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

// CHIBIFIRE
local godot_template_groups_editor_4_x = 'godot-template-groups-4-x';
local godot_template_groups_export_4_x = 'production-groups-release-export-4-x';

// STERN FLOWERS
local godot_template_stern_flowers_editor = 'godot-template-stern-flowers';
// END
local itch_fire_template = [godot_template_groups_editor_4_x] + [godot_template_groups_export_4_x];

local itch_stern_flowers_template = [godot_template_stern_flowers_editor];

{
  'env.fire.goenvironment.json': {
    name: 'itch-fire',
    pipelines: itch_fire_template,
    environment_variables:
      [],
  },
  'env.stern-flowers.goenvironment.json': {
    name: 'itch-stern-flowers',
    pipelines: itch_stern_flowers_template,
    environment_variables:
      [],
  },
  // STERN FLOWERS
  'godot_stern_flowers_editor.gopipeline.json'
  : std.prune(godot_pipeline_4_x(
    pipeline_name=godot_template_stern_flowers_editor,
    godot_status='stern-flowers',
    godot_git='https://github.com/godotengine/godot.git',
    godot_branch='master',
    gocd_group='stern-flowers'
  )),
  // GROUPS 4.x
  'godot_v_sekai_editor_4_x.gopipeline.json'
  : std.prune(godot_pipeline_4_x(
    pipeline_name=godot_template_groups_editor_4_x,
    godot_status='groups_4_x',
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch='groups-4.x',
    gocd_group='gamma',
    godot_modules_git='https://github.com/V-Sekai/godot-modules-groups.git',
    godot_modules_branch='groups-modules-4.x',
  )),
} + {
  'godot_groups_editor_export_4_x.gopipeline.json'
  : std.prune(
    godot_editor_export_4_x(
      pipeline_name=godot_template_groups_export_4_x,
      pipeline_dependency=godot_template_groups_editor_4_x,
      gocd_group='gamma',
      godot_status='groups_4_x',
      enabled_export_platforms=enabled_groups_export_platforms_4_x,
    )
  ),
}
