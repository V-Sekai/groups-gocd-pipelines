local HEADLESS_SERVER_EDITOR = 'godot_server.x11.opt.tools.64.llvm';

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
    intermediate_godot_binary: 'godot.x11.opt.tools.64.llvm',
    editor_godot_binary: 'godot.x11.opt.tools.64.llvm',
    template_debug_binary: 'linux_x11_64_debug',
    template_release_binary: 'linux_x11_64_release',
    export_directory: 'export_linux_x11',
    scons_platform: 'x11',
    gdnative_platform: 'linux',
    strip_command: 'strip --strip-debug',
    godot_scons_arguments: 'use_static_cpp=yes use_llvm=yes builtin_freetype=yes',
    extra_commands: [],
    environment_variables: [],
    template_artifacts_override: null,
    template_output_artifacts: null,
    template_extra_commands: [],
  },
  server: {
    platform_name: 'server',
    scons_env: '',
    intermediate_godot_binary: HEADLESS_SERVER_EDITOR,
    editor_godot_binary: HEADLESS_SERVER_EDITOR,
    template_debug_binary: 'server_64_debug',
    template_release_binary: 'server_64_release',
    export_directory: 'export_linux_server',
    scons_platform: 'server',
    gdnative_platform: 'linux',
    strip_command: 'strip --strip-debug',
    godot_scons_arguments: 'use_static_cpp=yes use_llvm=yes',  // FIXME: use_llvm=yes????
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

local enabled_engine_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'server', 'macos']];

local enabled_template_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'server', 'web', 'macos']];

local enabled_gdnative_platforms = [platform_info_dict[x] for x in ['windows', 'linux', 'macos']];


local groups_gdnative_plugins = {
  godot_speech: {
    name: 'godot_speech',
    pipeline_name: 'gdnative-godot-speech',
    git_url: 'https://github.com/V-Sekai/godot_speech.git',
    git_branch: 'master',
    platforms: {
      windows: {
        artifacts: [
          'bin/release/libGodotSpeech.dll',
        ],
        output_artifacts: [
          'libGodotSpeech.dll',
        ],
        debug_artifacts: [
          'bin/release/libGodotSpeech.dbg.dll',
          'bin/release/libGodotSpeech.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libGodotSpeech.dll libGodotSpeech.dbg.dll && mingw-strip --strip-debug -o libGodotSpeech.dll libGodotSpeech.dbg.dll',
        ],
        //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
      },
      linux: {
        artifacts: [
          'bin/release/libGodotSpeech.so',
        ],
        output_artifacts: [
          'libGodotSpeech.so',
        ],
        debug_artifacts: [
          'bin/release/libGodotSpeech.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libGodotSpeech.so libGodotSpeech.dbg.so && strip --strip-debug -o libGodotSpeech.so libGodotSpeech.dbg.so',
        ],
        //install_task: ["mv libGodotSpeech.so g/addons/godot_speech/bin/libGodotSpeech.so"],
      },
      osx: {
        artifacts: [
          "bin/release/libGodotSpeech.dylib"
        ],
        output_artifacts: [
          "libGodotSpeech.dylib"
        ],
        debug_artifacts: [
          "bin/release/libGodotSpeech.dbg.dylib"
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          "cd bin/release && mv libGodotSpeech.dylib libGodotSpeech.dbg.dylib && LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S -o libGodotSpeech.dylib libGodotSpeech.dbg.dylib"
        ],
        //install_task: ["mv libGodotSpeech.dylib g/addons/godot_speech/bin/libGodotSpeech.dylib"],
      },
    },
  },
  godot_openvr: {
    name: 'godot_openvr',
    pipeline_name: 'gdnative-godot-openvr',
    git_url: 'https://github.com/V-Sekai/godot_openvr.git',
    git_branch: 'groups',
    platforms: {
      windows: {
        artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
          'demo/addons/godot-openvr/bin/win64/openvr_api.dll',
        ],
        output_artifacts: [
          'libgodot_openvr.dll',
          'openvr_api.dll',
        ],
        debug_artifacts: [
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.dbg.dll',
          'demo/addons/godot-openvr/bin/win64/libgodot_openvr.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        // NOTE: We will use prebuilt openvr_api.dll
        prepare_commands: [
          'python wrap_openvr.py',
          'rm -f demo/addons/godot-openvr/bin/win64/libgodot_openvr.dll',
        ],
        extra_commands: [
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
        // NOTE: We will use prebuilt libopenvr_api.so
        prepare_commands: [
          'rm -f demo/addons/godot-openvr/bin/x11/libgodot_openvr.so',
        ],
        extra_commands: [
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
      }
    },
  },
  godot_gltf: {
    name: 'godot_gltf',
    pipeline_name: 'gdnative-godot-gltf',
    git_url: 'https://github.com/V-Sekai/godot-gltf-module.git',
    git_branch: 'gdnative',
    platforms: {
      windows: {
        artifacts: [
          'bin/release/libgodot_gltf.dll',
        ],
        output_artifacts: [
          'libgodot_gltf.dll',
        ],
        debug_artifacts: [
          'bin/release/libgodot_gltf.pdb',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
        ],
      },
      linux: {
        artifacts: [
          'bin/release/libgodot_gltf.so',
        ],
        output_artifacts: [
          'libgodot_gltf.so',
        ],
        debug_artifacts: [
          'bin/release/libgodot_gltf.dbg.so',
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          'cd bin/release && mv libgodot_gltf.so libgodot_gltf.dbg.so && strip --strip-debug -o libgodot_gltf.so libgodot_gltf.dbg.so',
        ],
      },
      osx: {
        artifacts: [
          "bin/release/libgodot_gltf.dylib"
        ],
        output_artifacts: [
          "libgodot_gltf.dylib"
        ],
        debug_artifacts: [
          "bin/release/libgodot_gltf.dbg.dylib"
        ],
        scons_arguments: '',
        environment_variables: [],
        prepare_commands: [],
        extra_commands: [
          "cd bin/release && mv libgodot_gltf.dylib libgodot_gltf.dbg.dylib && LD_LIBRARY_PATH=/opt/osxcross/target/bin /opt/osxcross/target/bin/x86_64-apple-darwin19-strip -S -o libgodot_gltf.dylib libgodot_gltf.dbg.dylib"
        ],
      },
    },
  },
};

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

local all_gdnative_plugins = [groups_gdnative_plugins[x] for x in ['godot_speech', 'godot_openvr', 'godot_gltf']];

local enabled_groups_gdnative_plugins = [groups_gdnative_plugins[x] for x in ['godot_speech', 'godot_openvr']];

local enabled_groups_export_platforms = [groups_export_configurations[x] for x in ['windows', 'linuxDesktop', 'linuxServer', 'web', 'macos']];

local exe_to_pdb_path(binary) = (std.substr(binary, 0, std.length(binary) - 4) + '.pdb');


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
    //    {
    //      name: 'butler_git_sandbox',
    //      url: gocd_build_git,
    //      type: 'git',
    //      branch: gocd_build_branch,
    //      destination: 'b',
    //    },
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
        for platform_info in enabled_engine_platforms
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
        for platform_info in enabled_template_platforms
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
              job: enabled_template_platforms[0].platform_name + 'Job',
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
            resources: [
              'linux',
              'mingw5',
            ],
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
                source: HEADLESS_SERVER_EDITOR,
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  // Due to a godot bug, the server crashes with "pure virtual function called"
                  'chmod +x ' + HEADLESS_SERVER_EDITOR + ' && HOME="`pwd`" ./' + HEADLESS_SERVER_EDITOR + ' --gdnative-generate-json-api api.json || [[ "$(cat api.json | tail -1)" = "]" ]]',
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
            name: platform_info.gdnative_platform + 'Job',
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
                source: 'godot-cpp/godot-headers',
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
                source: 'api.json',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.gdnative_platform + ' target=release -j`nproc` use_lto=no deprecated=no generate_bindings=yes custom_api_file=../api.json ' + platform_info.godot_scons_arguments,
                ],
                command: '/bin/bash',
                working_directory: 'godot-cpp',
              },
            ],
          }
          for platform_info in enabled_gdnative_platforms
        ],
      },
    ],
  };

local generate_godot_gdnative_pipeline(pipeline_name='',
                                       pipeline_dependency='',
                                       gocd_group='',
                                       godot_status='',
                                       library_info=null) =
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
        name: 'gdnativeBuildStage',
        jobs: [
          {
            name: platform_info.gdnative_platform + 'Job',
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
              for artifact_path in library_info.platforms[platform_info.gdnative_platform].artifacts
            ] + [
              {
                type: 'build',
                source: 'p/' + artifact_path,
                destination: 'debug',
              }
              for artifact_path in library_info.platforms[platform_info.gdnative_platform].debug_artifacts
            ],
            environment_variables: platform_info.environment_variables + library_info.platforms[platform_info.gdnative_platform].environment_variables,
            tasks: [
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                pipeline: pipeline_dependency,
                stage: 'godotCppStage',
                job: platform_info.gdnative_platform + 'Job',
                source: 'godot-cpp',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -f godot-cpp/godot-headers/.git && cp -a godot-cpp p',
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
              for extra_command in library_info.platforms[platform_info.gdnative_platform].prepare_commands
            ] + [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  platform_info.scons_env + 'scons werror=no platform=' + platform_info.gdnative_platform + ' target=release -j`nproc` use_lto=no deprecated=no ' + platform_info.godot_scons_arguments + library_info.platforms[platform_info.gdnative_platform].scons_arguments,
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
              for extra_command in library_info.platforms[platform_info.gdnative_platform].extra_commands
            ] + [
            ],
          }
          for platform_info in enabled_gdnative_platforms
          if std.objectHas(library_info.platforms, platform_info.gdnative_platform) && std.length(library_info.platforms[platform_info.gdnative_platform].artifacts) + std.length(library_info.platforms[platform_info.gdnative_platform].debug_artifacts) > 0
        ],
      },
    ],
  };

local godot_tools_pipeline_export(
  pipeline_name='',
  pipeline_dependency='',
  gdnative_plugins=[],
  itchio_login='',
  gocd_group='',
  godot_status='',
  gocd_project_folder='',
  groups_git='',
  groups_branch='',
  enabled_export_platforms=[],
      ) =
  {
    name: pipeline_name,
    group: gocd_group,
    label_template: godot_status + '.${groups_git_sandbox[:8]}.${' + pipeline_dependency + '_pipeline_dependency' + '}.${COUNT}',
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
    ] + [
      {
        name: library_info.pipeline_name + '_pipeline_dependency',
        type: 'dependency',
        pipeline: library_info.pipeline_name,
        stage: 'gdnativeBuildStage',
        ignore_for_scheduling: false,
      }
      for library_info in gdnative_plugins
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
                job: 'serverJob',
                is_source_a_file: true,
                source: HEADLESS_SERVER_EDITOR,
                destination: '',
              },
            ] + std.flatMap(function(library_info) [
                              {
                                type: 'fetch',
                                artifact_origin: 'gocd',
                                pipeline: library_info.pipeline_name,
                                stage: 'gdnativeBuildStage',
                                job: export_info.gdnative_platform + 'Job',
                                is_source_a_file: true,
                                source: artifact,
                                destination: library_info.name,
                              }
                              for artifact in library_info.platforms[export_info.gdnative_platform].output_artifacts
                            ],
                            gdnative_plugins) + std.flatMap(function(library_info) [
                                                              if std.endsWith(artifact, '.dll') && artifact != 'openvr_api.dll' then {
                                                                type: 'fetch',
                                                                artifact_origin: 'gocd',
                                                                pipeline: library_info.pipeline_name,
                                                                stage: 'gdnativeBuildStage',
                                                                job: export_info.gdnative_platform + 'Job',
                                                                is_source_a_file: true,
                                                                source: 'debug/' + exe_to_pdb_path(artifact),
                                                                destination: library_info.name,
                                                              } else null
                                                              for artifact in library_info.platforms[export_info.gdnative_platform].output_artifacts
                                                            ],
                                                            gdnative_plugins) + [
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
                  '(echo "## AUTOGENERATED BY BUILD"; echo ""; echo "const BUILD_LABEL = \\"$GO_PIPELINE_LABEL\\""; echo "const BUILD_DATE_STR = \\"$(date --utc --iso=seconds)\\""; echo "const BUILD_UNIX_TIME = $(date +%s)" ) > addons/vsk_version/build_constants.gd',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf ' + export_info.export_directory + ' && mkdir ' + export_info.export_directory + ' && chmod +x ' + HEADLESS_SERVER_EDITOR + ' && HOME="`pwd`" ./' + HEADLESS_SERVER_EDITOR + ' --export "' + export_info.export_configuration + '" "`pwd`"/' + export_info.export_directory + '/' + export_info.export_executable + ' --path g -v',
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
            //            environment_variables:
            //              [{
            //                name: 'BUTLER_API_KEY',
            //                encrypted_value: butler_api_key,
            //              },{name: 'ITCHIO_LOGIN', value: ....}],
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

local build_docker_server(
  pipeline_name='',
  pipeline_dependency='',
  gocd_group='',
  godot_status='',
  docker_groups_git='',
  docker_groups_branch='',
  docker_groups_dir='',
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
            environment_variables:
              [],
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
                  'set -x; DOCKER_IMAGE="$DOCKER_REPO_GROUPS_SERVER:$GO_PIPELINE_LABEL" ' +
                  '; chmod 01777 g/"' + docker_groups_dir + '"/' + groups_export_configurations.linuxServer.export_directory +
                  '; chmod a+x g/"' + docker_groups_dir + '"/' + groups_export_configurations.linuxServer.export_directory + '/' + groups_export_configurations.linuxServer.export_executable +
                  '; docker build -t "$DOCKER_REPO_GROUPS_SERVER" -t "$DOCKER_IMAGE"' +
                  ' --build-arg SERVER_EXPORT="' + server_export_info.export_directory + '"' +
                  ' --build-arg GODOT_REVISION="master"' +
                  ' --build-arg USER=1234' +
                  ' --build-arg HOME=/server' +
                  ' --build-arg GROUPS_REVISION="$GO_PIPELINE_LABEL"' +
                  ' g/"' + docker_groups_dir + '" && docker push "$DOCKER_IMAGE" && docker push "$DOCKER_REPO_GROUPS_SERVER"' +
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

local video_decoder_docker_job(pipeline_name='',
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
                source: 'g/target',
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
                  'chmod +x ./build_gdnative.sh && ./build_gdnative.sh',
                ],
                command: '/bin/bash',
                working_directory: 'g',
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
local godot_template_groups_editor = 'godot-template-groups';
local godot_cpp_pipeline = 'gdnative-cpp';
local godot_template_groups_export = 'production-groups-release-export';
local docker_pipeline = 'docker-groups';
local docker_uro_pipeline = 'docker-uro';
local docker_video_decoder_pipeline = 'docker-video-decoder';
// CHIBIFIRE
local godot_template_chibifire_editor = 'godot-template-chibifire';
// STERN FLOWERS
local godot_template_stern_flowers_editor = 'godot-template-stern-flowers';
// END
local godot_gdnative_pipelines =
  [plugin_info.pipeline_name for plugin_info in all_gdnative_plugins];


local godot_template = [godot_template_chibifire_editor] + [godot_template_stern_flowers_editor] + [godot_template_groups_editor, godot_cpp_pipeline] + godot_gdnative_pipelines + [godot_template_groups_export, docker_pipeline, docker_uro_pipeline, docker_video_decoder_pipeline];


{
  'env.goenvironment.json': {
    name: 'development',
    pipelines: godot_template,
    environment_variables:
      [],
  },
  // CHIBIFIRE
  'godot_chibifire_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_chibifire_editor,
    godot_status='chibifire',
    godot_git='https://github.com/godot-extended-libraries/godot-fire.git',
    godot_branch='extended-fire',
    gocd_group='chibifire',
    godot_modules_git='https://github.com/godot-extended-libraries/godot-modules-fire.git',
    godot_modules_branch='master',
  )),
  // STERN FLOWERS
  'godot_stern_flowers_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_stern_flowers_editor,
    godot_status='stern-flowers',
    godot_git='https://github.com/godotengine/godot.git',
    godot_branch='master',
    gocd_group='stern-flowers'
  )),
  // GROUPS
  'godot_groups_editor.gopipeline.json'
  : std.prune(godot_pipeline(
    pipeline_name=godot_template_groups_editor,
    godot_status='groups',
    godot_git='https://github.com/V-Sekai/godot.git',
    godot_branch='groups',
    gocd_group='beta',
    godot_modules_git='https://github.com/V-Sekai/godot-modules-groups.git',
    godot_modules_branch='groups',
  )),
  'gdnative_cpp.gopipeline.json'
  : std.prune(
    generate_godot_cpp_pipeline(
      pipeline_name=godot_cpp_pipeline,
      pipeline_dependency=godot_template_groups_editor,
      gocd_group='beta',
      godot_status='gdnative.godot-cpp'
    )
  ),
} + {
  ['gdnative_' + library_info.name + '.gopipeline.json']: generate_godot_gdnative_pipeline(
    pipeline_name=library_info.pipeline_name,
    pipeline_dependency=godot_cpp_pipeline,
    gocd_group='beta',
    godot_status='gdnative.' + library_info.name,
    library_info=library_info,
  )
  for library_info in all_gdnative_plugins
} + {
  'godot_groups_export.gopipeline.json'
  : std.prune(
    godot_tools_pipeline_export(
      pipeline_name=godot_template_groups_export,
      pipeline_dependency=godot_template_groups_editor,
      gdnative_plugins=enabled_groups_gdnative_plugins,
      groups_git='git@gitlab.com:SaracenOne/groups.git',
      groups_branch='master',
      gocd_group='beta',
      godot_status='v_sekai',
      gocd_project_folder='groups',
      enabled_export_platforms=enabled_groups_export_platforms,
    )
  ),
  'docker_groups.gopipeline.json'
  : std.prune(
    build_docker_server(
      pipeline_name=docker_pipeline,
      pipeline_dependency=godot_template_groups_export,
      docker_groups_git='https://github.com/V-Sekai/docker-groups.git',
      docker_groups_branch='master',
      docker_groups_dir='groups_server',
      gocd_group='beta',
      godot_status='docker',
      server_export_info=groups_export_configurations.linuxServer,
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
  'docker_video_decoder.gopipeline.json'
  : std.prune(
    video_decoder_docker_job(
      pipeline_name=docker_video_decoder_pipeline,
      gocd_group='beta',
      docker_git='https://github.com/V-Sekai/godot-videodecoder.git',
      docker_branch='master',
      docker_dir='.',
    )
  ),
}
