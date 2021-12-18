local HEADLESS_SERVER_EDITOR = 'godot.linuxbsd.opt.tools.64.llvm';

local platform_info_dict = {
  windows: {
    platform_name: 'windows',
    scons_env: 'PATH=/opt/llvm-mingw/bin:$PATH ',
    intermediate_godot_binary: 'godot.windows.opt.tools.64.exe',
    editor_godot_binary: 'godot.windows.opt.tools.64.exe',
    template_debug_binary: 'windows_64_debug.exe',
    template_release_binary: 'windows_64_release.exe',
    export_directory: 'export_windows',
    scons_platform: 'windows',
    gdextension_platform: 'windows',
    strip_command: 'mingw-strip --strip-debug',
    godot_scons_arguments: "use_mingw=yes use_llvm=yes use_thinlto=yes LINKFLAGS=-Wl,-pdb= CCFLAGS='-g -gcodeview' debug_symbols=no",
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
    template_debug_binary: 'linux_x11_64_debug',
    template_release_binary: 'linux_x11_64_release',
    export_directory: 'export_linuxbsd',
    scons_platform: 'linuxbsd',
    gdextension_platform: 'linux',
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
    intermediate_godot_binary: 'godot.javascript.opt.debug.threads.zip',
    editor_godot_binary: 'webassembly_release.zip',
    template_debug_binary: 'webassembly_debug.zip',
    template_release_binary: 'webassembly_release.zip',
    strip_command: null,  // unknown if release should be built separately.
    scons_platform: 'javascript',
    gdextension_platform: 'linux',  // TODO: We need godot_speech for web.
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
    editor_godot_binary: 'Godot.app',
    template_debug_binary: 'godot_osx_debug.64',
    template_release_binary: 'godot_osx_release.64',
    scons_platform: 'osx',
    gdextension_platform: 'osx',
    strip_command: 'LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S',
    godot_scons_arguments: 'osxcross_sdk=darwin19 CXXFLAGS="-Wno-deprecated-declarations -Wno-error " builtin_freetype=yes use_static_mvk=yes',
    extra_commands: [
      'OSXCROSS_ROOT="LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross" scons platform=osx arch=arm64 osxcross_sdk=darwin19 CXXFLAGS="-Wno-deprecated-declarations -Wno-error " builtin_freetype=yes use_static_mvk=yes',
      'lipo -create bin/godot.osx.tools.x86_64 bin/godot.osx.tools.arm64 -output bin/godot.osx.tools.universal',
      'rm -rf ./bin/Godot.app',
      'cp -r ./misc/dist/osx_tools.app ./bin/',
      'cp bin/godot.osx.opt.tools.universal ./bin/Godot.app/Contents/MacOS/Godot',
      'chmod +x ./bin/Godot.app/Contents/MacOS/Godot',
    ],
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
      'cp ./bin/godot.osx.opt.universal osx_template.app/Contents/MacOS/godot_osx_release.64',
      'cp ./bin/godot.osx.opt.universal osx_template.app/Contents/MacOS/godot_osx_debug.64',
      'chmod +x osx_template.app/Contents/MacOS/godot_osx*',
      'rm -rf bin/osx.zip',
      'cd bin && zip -9 -r osx.zip osx_template.app/',
      'cd .. && rm -rf Godot.app && cp -r ./g/misc/dist/osx_template.app Godot.app',
    ],
  },
};

local enabled_engine_platforms = [platform_info_dict[x] for x in ['windows', 'linux']];
local enabled_groups_engine_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'web']];

local enabled_template_platforms = [platform_info_dict[x] for x in ['windows', 'linux']];
local enabled_groups_template_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'web']];

local enabled_gdextension_platforms = [platform_info_dict[x] for x in ['windows', 'linux']];
local enabled_groups_gdextension_platforms = [platform_info_dict[x] for x in ['windows', 'linux']];


local groups_gdextension_plugins = {
  godot_openvr: {
    name: 'godot_openvr',
    pipeline_name: 'gdextension-godot-openvr',
    git_url: 'https://github.com/V-Sekai/godot_openvr.git',
    git_branch: 'groups-4.0',
    platforms: {
      windows: {
        artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
          'demo/addons/godot-openvr/bin/win64/openvr_api.dll',
          'demo/addons/godot-openvr/bin/win64/openvr_api.dll.sig',
        ],
        output_artifacts: [
          'libgodot_openvr.dll',
        ],
        debug_artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dbg.dll',
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.pdb',
          'demo/addons/godot-openvr/bin/win64/openvr_api.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [
          'python wrap_openvr.py',
          'rm -f demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
        ],
        extra_commands: [
          'cp -a openvr/bin/win64/openvr_api.dll demo/addons/godot-openvr/bin/win64/openvr_api.dll',
          'cp -a openvr/bin/win64/openvr_api.dll.sig demo/addons/godot-openvr/bin/win64/openvr_api.dll.sig',
          'cp -a openvr/bin/win64/openvr_api.pdb demo/addons/godot-openvr/bin/win64/openvr_api.pdb',
          'cd demo/addons/godot-openvr/bin/win64 && mv libgodot_openvr.dll libgodot_openvr.dbg.dll && mingw-strip --strip-debug -o libgodot_openvr.dll libgodot_openvr.dbg.dll',
        ],
        //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
      },
      linux: {
        artifacts: [
          'demo/addons/godot-openvr/bin/x11/libgodot_openvr.so',
          'demo/addons/godot-openvr/bin/x11/libopenvr_api.so',
        ],
        output_artifacts: [
          'libgodot_openvr.so',
          'libopenvr_api.so',
        ],
        debug_artifacts: [
          'demo/addons/godot-openvr/bin/x11/libgodot_openvr.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [
          'rm -f demo/addons/godot-openvr/bin/x11/libgodot_openvr.so',
        ],
        extra_commands: [
          'cp -a openvr/bin/linux64/libopenvr_api.so demo/addons/godot-openvr/bin/x11/libopenvr_api.so',
          'cp -a openvr/bin/linux64/libopenvr_api.so.dbg demo/addons/godot-openvr/bin/x11/libopenvr_api.so.dbg',
          'cd demo/addons/godot-openvr/bin/x11 && mv libgodot_openvr.so libgodot_openvr.dbg.so && strip --strip-debug -o libgodot_openvr.so libgodot_openvr.dbg.so',
        ],
        //install_task: ["mv libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so"],
      },
      osx: {
        artifacts: [],
        output_artifacts: [],
        debug_artifacts: [],
        scons_arguments: ' --version',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [],
      },
    },
  },
  godot_openxr: {
    name: 'godot_openxr',
    pipeline_name: 'gdextension-godot-openxr',
    git_url: 'https://github.com/V-Sekai/godot_openxr.git',
    git_branch: 'groups-4.0',
    platforms: {
      windows: {
        artifacts: [
          'demo/addons/godot-openxr/bin/win64/libgodot_openxr.dll',
          'demo/addons/godot-openxr/bin/win64/openxr_api.dll',
          'demo/addons/godot-openxr/bin/win64/openxr_api.dll.sig',
        ],
        output_artifacts: [
          'libgodot_openxr.dll',
        ],
        debug_artifacts: [
          'demo/addons/godot-openxr/bin/win64/libgodot_openxr.dbg.dll',
          'demo/addons/godot-openxr/bin/win64/libgodot_openxr.pdb',
          'demo/addons/godot-openxr/bin/win64/openxr_api.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [
          'rm -f demo/addons/godot-openxr/bin/win64/libgodot_openxr.dll',
        ],
        extra_commands: [
          'cd demo/addons/godot-openxr/bin/win64 && mv libgodot_openxr.dll libgodot_openxr.dbg.dll && mingw-strip --strip-debug -o libgodot_openxr.dll libgodot_openxr.dbg.dll',
        ],
        //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
      },
      linux: {
        artifacts: [
          'demo/addons/godot-openxr/bin/x11/libgodot_openxr.so',
          'demo/addons/godot-openxr/bin/x11/libopenxr_api.so',
        ],
        output_artifacts: [
          'libgodot_openxr.so',
          'libopenxr_api.so',
        ],
        debug_artifacts: [
          'demo/addons/godot-openxr/bin/x11/libgodot_openxr.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [
          'rm -f demo/addons/godot-openxr/bin/x11/libgodot_openxr.so',
        ],
        extra_commands: [
          'cp -a openxr/bin/linux64/libopenxr_api.so demo/addons/godot-openxr/bin/x11/libopenxr_api.so',
          'cp -a openxr/bin/linux64/libopenxr_api.so.dbg demo/addons/godot-openxr/bin/x11/libopenxr_api.so.dbg',
          'cd demo/addons/godot-openxr/bin/x11 && mv libgodot_openxr.so libgodot_openxr.dbg.so && strip --strip-debug -o libgodot_openxr.so libgodot_openxr.dbg.so',
        ],
      },
      osx: {
        artifacts: [],
        output_artifacts: [],
        debug_artifacts: [],
        scons_arguments: ' --version',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [],
      },
    },
  },
};

// TODO: Use std.escapeStringBash in case export configurations wish to output executables with spaces.
local groups_export_configurations = {
  windows: {
    export_name: 'windows',
    platform_name: 'windows',
    gdextension_platform: 'windows',
    export_configuration: 'Windows Desktop',
    export_directory: 'export_windows',
    export_executable: 'v_sekai_windows.exe',
    itchio_out: 'windows-master',
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
  linuxDesktop: {
    export_name: 'linuxDesktop',
    platform_name: 'linux',
    gdextension_platform: 'linux',
    export_configuration: 'Linux/X11',
    export_directory: 'export_linuxbsd',
    export_executable: 'v_sekai_linuxbsd',
    itchio_out: 'linux-master',
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
  macos: {
    export_name: 'macos',
    platform_name: 'macos',
    gdextension_platform: 'osx',
    export_configuration: 'Mac OSX',
    export_directory: 'export_macos',
    export_executable: 'macos.zip',
    itchio_out: 'macos',
    prepare_commands: [
    ],
    extra_commands: [
      // https://itch.io/t/303643/cant-get-a-mac-app-to-run-after-butler-push-resolved
      'cd export_macos && unzip macos.zip && rm macos.zip',
    ],
  },
  web: {
    export_name: 'web',
    platform_name: 'web',
    gdextension_platform: 'linux',
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

// TODO: Use std.escapeStringBash in case export configurations wish to output executables with spaces.
local stern_flowers_export_configurations = {
  windows: {
    export_name: 'windows',
    platform_name: 'windows',
    gdextension_platform: 'windows',
    export_configuration: 'Windows Desktop',
    export_directory: 'export_windows',
    export_executable: 'godot.windows.opt.tools.64.exe',
    itchio_out: 'windows-master',
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
  linuxDesktop: {
    export_name: 'linuxDesktop',
    platform_name: 'linux',
    gdextension_platform: 'linux',
    export_configuration: 'Linux/X11',
    export_directory: 'export_linuxbsd',
    export_executable: 'godot.linuxbsd.opt.tools.64.llvm',
    itchio_out: 'linux-master',
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
  macos: {
    export_name: 'macos',
    platform_name: 'macos',
    gdextension_platform: 'osx',
    export_configuration: 'Mac OSX',
    export_directory: 'export_macos',
    export_executable: 'macos.zip',
    itchio_out: 'macos',
    prepare_commands: [
    ],
    extra_commands: [
      // https://itch.io/t/303643/cant-get-a-mac-app-to-run-after-butler-push-resolved
      'cd export_macos && unzip macos.zip && rm macos.zip',
    ],
  },
  web: {
    export_name: 'web',
    platform_name: 'web',
    gdextension_platform: 'linux',
    export_configuration: 'HTML5',
    export_directory: 'export_web',
    export_executable: 'godot_web.html',
    itchio_out: null,
    prepare_commands: [
    ],
    extra_commands: [
    ],
  },
};


local enabled_stern_flowers_export_platforms = [stern_flowers_export_configurations[x] for x in ['windows', 'linuxDesktop']];
local enabled_groups_export_platforms = [groups_export_configurations[x] for x in ['windows', 'linuxDesktop']];

local all_gdextension_plugins = [groups_gdextension_plugins[x] for x in ['godot_openvr']];

local exe_to_pdb_path(binary) = (std.substr(binary, 0, std.length(binary) - 4) + '.pdb');

local godot_pipeline(pipeline_name='',
                     godot_status='',
                     godot_git='',
                     godot_branch='',
                     gocd_group='',
                     godot_modules_git='',
                     godot_modules_branch='',
                     godot_engine_platforms=enabled_engine_platforms,
                     godot_template_platforms=enabled_template_platforms) = {
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
                  'cp -p g/bin/' + platform_info.intermediate_godot_binary + ' g/bin/' + platform_info.editor_godot_binary,
                ],
                command: '/bin/bash',
              }
            else null,
          ],
        }
        for platform_info in godot_engine_platforms
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
        for platform_info in godot_template_platforms
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
              job: godot_template_platforms[0].platform_name + 'Job',
            },
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: exe_to_pdb_path(platform_info_dict.windows.editor_godot_binary),
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
          ], godot_template_platforms) + [
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


local generate_godot_cpp_pipeline(pipeline_name='',
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
        branch: 'groups-4.0',
        destination: 'godot-cpp',
        shallow_clone: false,
        ignore_for_scheduling: false,
      },
      {
        name: 'godot-headers',
        url: 'https://github.com/godotengine/godot-headers.git',
        type: 'git',
        branch: 'master',
        destination: 'godot-headers',
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
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'extension_api.json',
                destination: '',
              },
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: 'linuxJob',
                is_source_a_file: true,
                source: HEADLESS_SERVER_EDITOR,
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'chmod +x ' + HEADLESS_SERVER_EDITOR + ' && ./' + HEADLESS_SERVER_EDITOR + ' --headless --dump-extension-api extension_api.json || true',
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
            name: platform_info.gdextension_platform + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'godot-cpp/include',
                destination: 'godot-cpp',
              },
              {
                type: 'build',
                source: 'godot-headers',
                destination: '',
              },
              {
                type: 'build',
                source: 'godot-cpp/gen/include',
                destination: 'godot-cpp',
              },
              {
                type: 'build',
                source: 'godot-cpp/bin',
                destination: 'godot-cpp',
              },
            ],
            environment_variables: platform_info.environment_variables,
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_name,
                stage: 'generateApiJsonStage',
                job: 'generateApiJsonJob',
                is_source_a_file: true,
                source: 'extension_api.json',
                destination: 'godot-headers',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.gdextension_platform + ' target=debug -j`nproc` use_lto=no deprecated=no generate_bindings=yes headers_dir=../godot-headers ' + platform_info.godot_scons_arguments,
                ],
                command: '/bin/bash',
                working_directory: 'godot-cpp',
              },
            ],
          }
          for platform_info in enabled_gdextension_platforms
        ],
      },
    ],
  };


local generate_godot_gdextension_pipeline(pipeline_name='',
                                          pipeline_dependency='',
                                          gocd_group='',
                                          godot_status='',
                                          library_info=null,
                                          godot_gdextension_platforms=enabled_gdextension_platforms) =
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
        stage: 'godotCppStage',
      },
      {
        name: 'p',
        url: library_info.git_url,
        type: 'git',
        branch: library_info.git_branch,
        destination: 'p',
        shallow_clone: false,
        ignore_for_scheduling: false,
      },
    ],
    stages: [
      {
        name: 'gdextensionBuildStage',
        jobs: [
          {
            name: platform_info.gdextension_platform + 'Job',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'p/' + artifact_path,
                destination: '',
              }
              for artifact_path in library_info.platforms[platform_info.gdextension_platform].artifacts
            ] + [
              {
                type: 'build',
                source: 'p/' + artifact_path,
                destination: 'debug',
              }
              for artifact_path in library_info.platforms[platform_info.gdextension_platform].debug_artifacts
            ],
            environment_variables: platform_info.environment_variables + library_info.platforms[platform_info.gdextension_platform].environment_variables,
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'godotCppStage',
                job: platform_info.gdextension_platform + 'Job',
                source: 'godot-cpp',
                destination: '',
              },
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'godotCppStage',
                job: platform_info.gdextension_platform + 'Job',
                source: 'godot-headers',
                destination: 'godot-cpp',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp -a godot-cpp/. p/godot-cpp',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_command,
                ],
                command: '/bin/bash',
                working_directory: 'p',
              }
              for extra_command in library_info.platforms[platform_info.gdextension_platform].prepare_commands
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.gdextension_platform + ' target=debug -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments + library_info.platforms[platform_info.gdextension_platform].scons_arguments,
                ],
                command: '/bin/bash',
                working_directory: 'p',
              },
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  extra_command,
                ],
                command: '/bin/bash',
                working_directory: 'p',
              }
              for extra_command in library_info.platforms[platform_info.gdextension_platform].extra_commands
            ] + [
            ],
          }
          for platform_info in godot_gdextension_platforms
          if std.objectHas(library_info.platforms, platform_info.gdextension_platform) && std.length(library_info.platforms[platform_info.gdextension_platform].artifacts) + std.length(library_info.platforms[platform_info.gdextension_platform].debug_artifacts) > 0
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
    label_template: pipeline_name + '.${COUNT}',
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
        clean_workspace: true,
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
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + 'Job',
                is_source_a_file: true,
                source: export_info.export_executable,
                destination: export_info.export_directory,
              },
              if std.endsWith(export_info.export_executable, '.exe') then {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: export_info.platform_name + 'Job',
                is_source_a_file: true,
                source: exe_to_pdb_path(export_info.export_executable),
                destination: export_info.export_directory,
              } else null,
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'templateZipStage',
                job: 'defaultJob',
                is_source_a_file: true,
                source: 'godot.templates.tpz',
                destination: export_info.export_directory,
              },
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

local godot_tools_pipeline_export(
  pipeline_name='',
  pipeline_dependency='',
  gdextension_plugins=[],
  itchio_login='',
  gocd_group='',
  godot_status='',
  gocd_project_folder='',
  project_git='',
  project_branch='',
  enabled_export_platforms=[],
  vsk=true,
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
        name: 'project_git_sandbox',
        url: project_git,
        type: 'git',
        branch: project_branch,
        destination: 'g',
      },
      {
        name: pipeline_dependency + '_pipeline_dependency',
        type: 'dependency',
        pipeline: pipeline_dependency,
        stage: 'templateZipStage',
        ignore_for_scheduling: false,
      },
    ] + [
      {
        name: library_info.pipeline_name + '_pipeline_dependency',
        type: 'dependency',
        pipeline: library_info.pipeline_name,
        stage: 'gdextensionBuildStage',
        ignore_for_scheduling: false,
      }
      for library_info in gdextension_plugins
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
              },
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'defaultStage',
                job: 'linuxJob',
                is_source_a_file: true,
                source: 'godot.linuxbsd.opt.tools.64.llvm',
                destination: '',
              },
            ] + std.flatMap(function(library_info) [
                              {
                                type: 'fetch',
                                artifact_origin: 'gocd',
                                pipeline: library_info.pipeline_name,
                                stage: 'gdextensionBuildStage',
                                job: export_info.gdextension_platform + 'Job',
                                is_source_a_file: true,
                                source: artifact,
                                destination: library_info.name,
                              }
                              for artifact in library_info.platforms[export_info.gdextension_platform].output_artifacts
                            ],
                            gdextension_plugins) + std.flatMap(function(library_info) [
                                                                 if std.endsWith(artifact, '.dll') && artifact != 'openvr_api.dll' then {
                                                                   type: 'fetch',
                                                                   artifact_origin: 'gocd',
                                                                   pipeline: library_info.pipeline_name,
                                                                   stage: 'gdextensionBuildStage',
                                                                   job: export_info.gdextension_platform + 'Job',
                                                                   is_source_a_file: true,
                                                                   source: 'debug/' + exe_to_pdb_path(artifact),
                                                                   destination: library_info.name,
                                                                 } else null
                                                                 for artifact in library_info.platforms[export_info.gdextension_platform].output_artifacts
                                                               ],
                                                               gdextension_plugins) + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf templates && unzip "godot.templates.tpz" && mkdir pdbs && mv templates/*.pdb pdbs && export VERSION="`cat templates/version.txt`" && export TEMPLATEDIR=".local/share/godot/templates/$VERSION/" && export HOME="`pwd`" && export BASEDIR="`pwd`" && rm -rf "$TEMPLATEDIR" && mkdir -p "$TEMPLATEDIR" && cd "$TEMPLATEDIR" && mv "$BASEDIR"/templates/* .',
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
              if vsk then
                {
                  type: 'exec',
                  arguments: [
                    '-c',
                    '(echo "## AUTOGENERATED BY BUILD"; echo ""; echo "const BUILD_LABEL = \\"$GO_PIPELINE_LABEL\\""; echo "const BUILD_DATE_STR = \\"$(date --utc --iso=seconds)\\""; echo "const BUILD_UNIX_TIME = $(date +%s)" ) > addons/vsk_version/build_constants.gd',
                  ],
                  command: '/bin/bash',
                  working_directory: 'g',
                } else null,
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf ' + export_info.export_directory + ' && mkdir -p g/.godot/editor && mkdir -p g/.godot/imported && mkdir ' + export_info.export_directory + ' && chmod +x ' + 'godot.linuxbsd.opt.tools.64.llvm' + ' && XDG_DATA_HOME=`pwd`/.local/share/ ./godot.linuxbsd.opt.tools.64.llvm --headless --export "' + export_info.export_configuration + '" `pwd`/' + export_info.export_directory + '/' + export_info.export_executable + ' --path g',
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
                  'butler push ' + export_info.export_directory + ' ' + itchio_login + ':' + export_info.itchio_out + ' --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
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


local build_docker_server(
  pipeline_name='',
  pipeline_dependency='',
  gocd_group='',
  godot_status='',
  docker_groups_git='',
  docker_groups_branch='',
  docker_groups_dir='',
  docker_repo_groups_server='',
  server_export_info={},
      ) =
  {
    name: pipeline_name,
    group: gocd_group,
    label_template: '${' + pipeline_dependency + '_pipeline_dependency' + '}.${COUNT}',
    environment_variables:
      [],
    materials: [
      {
        name: 'docker_groups_git',
        url: docker_groups_git,
        type: 'git',
        branch: docker_groups_branch,
        destination: 'g',
      },
      {
        name: pipeline_dependency + '_pipeline_dependency',
        type: 'dependency',
        pipeline: pipeline_dependency,
        stage: 'exportStage',
        ignore_for_scheduling: false,
      },
    ],
    stages: [
      {
        name: 'buildPushStage',
        clean_workspace: false,
        fetch_materials: true,
        jobs: [
          {
            name: 'dockerJob',
            resources: [
              'dind',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'docker_image.txt',
                destination: '',
              },
            ],
            environment_variables: [
            ],
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'exportStage',
                job: server_export_info.export_name + 'Job',
                is_source_a_file: false,
                source: server_export_info.export_directory,
                destination: 'g/' + docker_groups_dir,
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'ls "g/' + docker_groups_dir + '/' + server_export_info.export_directory + '"'
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'chmod 01777 "g/' + docker_groups_dir + '"'
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'chmod a+x g/"' + docker_groups_dir + '/' + server_export_info.export_executable + '"'
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'ls "g/' + docker_groups_dir + '/' + server_export_info.export_executable + '"'
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c', 
                  'docker build -t ' + docker_repo_groups_server + ':$GO_PIPELINE_LABEL' +
                  ' --build-arg SERVER_EXPORT="' + server_export_info.export_directory + '"' +
                  ' --build-arg GODOT_REVISION="master"' +
                  ' --build-arg USER=1234' +
                  ' --build-arg HOME=/server' +
                  ' --build-arg GROUPS_REVISION="$GO_PIPELINE_LABEL"' +
                  ' g/"' + docker_groups_dir + '"'
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'docker push "'+ docker_repo_groups_server + ':$GO_PIPELINE_LABEL"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'echo "' + docker_repo_groups_server + ':$GO_PIPELINE_LABEL" > docker_image.txt',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
        ],
      },
    ],
  };


local simple_docker_job(pipeline_name='',
                        gocd_group='',
                        docker_repo_variable='',
                        docker_git='',
                        docker_branch='',
                        docker_dir='') =
  {
    name: pipeline_name,
    group: gocd_group,
    label_template: '${' + pipeline_name + '_git[:8]}.${COUNT}',
    environment_variables:
      [],
    materials: [
      {
        name: pipeline_name + '_git',
        url: docker_git,
        type: 'git',
        branch: docker_branch,
        destination: 'g',
      },
    ],
    stages: [
      {
        name: 'buildPushStage',
        clean_workspace: false,
        fetch_materials: true,
        jobs: [
          {
            name: 'dockerJob',
            resources: [
              'dind',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'docker_image.txt',
                destination: '',
              },
            ],
            environment_variables:
              [],
            tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'set -x; DOCKER_IMAGE="$' + docker_repo_variable + ':$GO_PIPELINE_LABEL" ' +
                  '; docker build -t "$' + docker_repo_variable + '" -t "$DOCKER_IMAGE"' +
                  ' g/"' + docker_dir + '" && docker push "$DOCKER_IMAGE" && docker push "$' + docker_repo_variable + '"' +
                  ' && echo "$DOCKER_IMAGE" > docker_image.txt',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
        ],
      },
    ],
  };
// Groups
local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
// CHIBIFIRE
local godot_template_groups_editor = 'godot-template-groups-4-x';
local godot_template_groups_export = 'groups-editor-4-x';
local godot_template_groups = 'groups-4-x-export';
local godot_cpp_pipeline = 'gdextension-cpp';
// STERN FLOWERS
local godot_template_stern_flowers_editor = 'godot-template-stern-flowers-4-x';
local godot_template_stern_flowers_export = 'stern-flowers-editor-4-x';
// END
local godot_gdextension_pipelines =
  [plugin_info.pipeline_name for plugin_info in all_gdextension_plugins];

local itch_fire_template = [docker_pipeline, docker_uro_pipeline] + [godot_template_groups_editor, godot_cpp_pipeline] + godot_gdextension_pipelines + [godot_template_groups_export] + [godot_template_groups];
local itch_stern_flowers_template = [godot_template_stern_flowers_editor] + [godot_template_stern_flowers_export];

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
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_stern_flowers_editor,
    godot_status='stern-flowers-4.0',
    godot_git='https://github.com/godotengine/godot.git',
    godot_branch='master',
    gocd_group='delta',
  )),
  // GROUPS 4.x
  'godot_v_sekai_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_groups_editor,
    godot_status='groups-4.0',
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch='groups-4.x',
    gocd_group='gamma',
    godot_modules_git='https://github.com/V-Sekai/godot-modules-groups.git',
    godot_modules_branch='groups-modules-4.x',
    godot_engine_platforms=enabled_groups_engine_platforms,
    godot_template_platforms=enabled_groups_template_platforms
  )),
  'gdextension_cpp.gopipeline.json'
  : std.prune(
    generate_godot_cpp_pipeline(
      pipeline_name=godot_cpp_pipeline,
      pipeline_dependency=godot_template_groups_editor,
      gocd_group='gamma',
      godot_status='gdextension.godot-cpp'
    )
  ),
} + {
  ['gdextension_' + library_info.name + '.gopipeline.json']: generate_godot_gdextension_pipeline(
    pipeline_name=library_info.pipeline_name,
    pipeline_dependency=godot_cpp_pipeline,
    gocd_group='gamma',
    godot_status='gdextension.' + library_info.name,
    library_info=library_info,
    godot_gdextension_platforms=enabled_groups_gdextension_platforms,
  )
  for library_info in all_gdextension_plugins
} + {
  'godot_groups_editor_export.gopipeline.json'
  : std.prune(
    godot_editor_export(
      pipeline_name=godot_template_groups_export,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='ifiregames/chibifire-godot-4-custom-engine',
      gocd_group='gamma',
      godot_status='groups-4.0',
      enabled_export_platforms=enabled_stern_flowers_export_platforms,
    )
  ),
} + {
  'godot_template_groups_export.gopipeline.json'
  : std.prune(
    godot_tools_pipeline_export(
      pipeline_name=godot_template_groups,
      pipeline_dependency=godot_template_groups_editor,
      itchio_login='saracenone/groups-4x',
      project_git='git@gitlab.com:SaracenOne/groups.git',
      project_branch='godot4',
      gocd_group='gamma',
      godot_status='groups-4.0',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
} + {
  'godot_stern_flowers_editor_export.gopipeline.json'
  : std.prune(
    godot_editor_export(
      pipeline_name=godot_template_stern_flowers_export,
      pipeline_dependency=godot_template_stern_flowers_editor,
      itchio_login='ifiregames/stern-flowers-chibifire-com-godot-engine',
      gocd_group='delta',
      godot_status='stern-flowers-4.0',
      enabled_export_platforms=enabled_stern_flowers_export_platforms,
    )
  ),
  'docker_groups.gopipeline.json'
  : std.prune(
    build_docker_server(
      pipeline_name=docker_pipeline,
      pipeline_dependency=godot_template_groups,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='beta',
      godot_status='docker',
      docker_repo_groups_server='groupsinfra/groups-server',
      server_export_info=groups_export_configurations.linuxDesktop,
    )
  ),
  'docker_uro.gopipeline.json'
  : std.prune(
    simple_docker_job(
      pipeline_name=docker_uro_pipeline,
      gocd_group='beta',
      docker_repo_variable='DOCKER_URO_REPO',
      docker_git='https://github.com/V-Sekai/uro.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
}
