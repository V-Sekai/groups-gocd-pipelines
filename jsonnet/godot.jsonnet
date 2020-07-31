local godot_pipeline(pipeline_name='',
                     godot_status='',
                     godot_git='',
                     godot_branch='',
                     gocd_group='',
                     linux_app_description='',
                     linux_app_server_description='',
                     disable_server=false,
                     disable_web=false,
                     disable_osx=false,
                     linux_platform_name='x11',
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
          name: 'defaultJob',
          resources: [
            'mingw5',
            'linux',
          ],
          artifacts: [
            {
              source: 'g/bin/godot.windows.opt.tools.64.exe',
              destination: '',
              type: 'build',
            },
          ],
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
                'scons werror=no platform=windows target=release_debug -j`nproc` use_lto=no deprecated=no use_llvm=no use_lld=yes' +
                if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
          ],
        },
        {
          name: 'linuxJob',
          resources: [
            'linux',
            'mingw5',
          ],
          artifacts: [
            {
              type: 'build',
              source: 'g/bin/godot.' + linux_platform_name + '.opt.tools.64.llvm',
              destination: '',
            },
          ],
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
                'scons werror=no platform=x11 target=release_debug -j`nproc` use_lto=no deprecated=no use_llvm=yes builtin_freetype=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
          ],
        },


        if disable_server == false then
          {
            name: 'serverJob',
            artifacts: [
              {
                type: 'build',
                source: 'g/bin/godot_server.' + linux_platform_name + '.opt.tools.64',
                destination: '',
              },
            ],
            resources: [
              'linux',
              'mingw5',
            ],
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
                  'scons werror=no platform=server target=release_debug -j`nproc` use_lto=no deprecated=no' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
            ],
          }
        else null
        ,
        if disable_osx == false then
          {
            name: 'osxJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'Godot',
              },
            ],
            environment_variables: [
              {
                name: 'PATH',
                value: '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
              },
            ],
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
                  'OSXCROSS_ROOT=/opt/osxcross scons werror=no platform=osx target=release_debug -j`nproc` use_lto=no deprecated=no osxcross_sdk=darwin19 CXXFLAGS="-Wno-deprecated-declarations -Wno-error " builtin_freetype=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp g/bin/godot.osx.opt.tools.64 Godot',
                ],
                command: '/bin/bash',
              },
            ],
          }
        else null,
      ],
    },
    {
      name: 'templateStage',
      jobs: [
        {
          name: 'windowsJob',
          resources: [
            'linux',
            'mingw5',
          ],
          artifacts: [
            {
              type: 'build',
              source: 'g/bin/windows_64_debug.exe',
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/windows_64_release.exe',
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/version.txt',
              destination: '',
            },
          ],
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
                'scons werror=no platform=windows target=release_debug -j`nproc` use_lto=no deprecated=no use_llvm=no use_lld=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'cp bin/godot.windows.opt.tools.64.exe bin/windows_64_debug.exe && cp bin/godot.windows.opt.tools.64.exe bin/windows_64_release.exe && mingw-strip --strip-debug bin/windows_64_release.exe',
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
        },
        {
          name: 'linuxJob',
          artifacts: [
            {
              type: 'build',
              source: 'g/bin/linux_x11_64_release',
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/linux_x11_64_debug',
              destination: '',
            },
            {
              type: 'build',
              source: 'g/bin/version.txt',
              destination: '',
            },
          ],
          resources: [
            'linux',
            'mingw5',
          ],
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
                'scons werror=no platform=x11 target=release_debug -j`nproc` use_lto=no deprecated=no use_llvm=yes builtin_freetype=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
              ],
              command: '/bin/bash',
              working_directory: 'g',
            },
            {
              type: 'exec',
              arguments: [
                '-c',
                'cp bin/godot.' + linux_platform_name + '.opt.tools.64.llvm bin/linux_x11_64_debug && cp bin/godot.' + linux_platform_name + '.opt.tools.64.llvm bin/linux_x11_64_release && strip --strip-debug bin/linux_x11_64_release',
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
        },
        if disable_web == false then
          {
            name: 'webJob',
            artifacts: [
              {
                type: 'build',
                source: 'g/bin/webassembly_release.zip',
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/webassembly_debug.zip',
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/version.txt',
                destination: '',
              },
            ],
            resources: [
              'linux',
              'mingw5',
            ],
            tasks: [
              {
                type: 'exec',
                arguments: [
                  '-c',
                  '/opt/emsdk/emsdk activate latest',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
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
                  'scons werror=no platform=javascript target=release_debug -j`nproc` use_lto=no deprecated=no use_llvm=yes builtin_freetype=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp bin/godot.javascript.opt.debug.zip bin/webassembly_debug.zip',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'scons werror=no platform=javascript target=release -j`nproc` use_lto=no deprecated=no use_llvm=yes builtin_freetype=yes' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp bin/godot.javascript.opt.zip bin/webassembly_release.zip',
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
          },
        if disable_server == false then
          {
            name: 'serverJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'g/bin/server_64_release',
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/server_64_debug',
                destination: '',
              },
              {
                type: 'build',
                source: 'g/bin/version.txt',
                destination: '',
              },
            ],
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
                  'scons werror=no platform=server target=release_debug -j`nproc` use_lto=no deprecated=no' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'cp bin/godot_server.' + linux_platform_name + '.opt.debug.64 bin/server_64_debug && cp bin/godot_server.' + linux_platform_name + '.opt.debug.64 bin/server_64_release && strip --strip-debug bin/server_64_release',
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
          },

        if disable_osx == false then
          {
            name: 'osxJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
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
            environment_variables: [
              {
                name: 'PATH',
                value: '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
              },
            ],
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
                  'OSXCROSS_ROOT=/opt/osxcross scons werror=no platform=osx target=release_debug -j`nproc` use_lto=no deprecated=no osxcross_sdk=darwin19 CXXFLAGS=" -Wno-error -Wno-deprecated-declarations "' + if godot_modules_git != '' then ' custom_modules=../godot_custom_modules' else '',
                ],
                command: '/bin/bash',
                working_directory: 'g',
              },
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
          }
        else null,
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
              source: 'windows_64_release.exe',
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'templateStage',
              job: 'windowsJob',
            },
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: 'windows_64_debug.exe',
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'templateStage',
              job: 'windowsJob',
            },
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: 'version.txt',
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'templateStage',
              job: 'windowsJob',
            },
            if disable_server == false then
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'server_64_release',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: 'serverJob',
              } else null,
            if disable_server == false then
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'server_64_debug',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: 'serverJob',
              } else null,
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: 'linux_x11_64_release',
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'templateStage',
              job: 'linuxJob',
            },
            {
              type: 'fetch',
              artifact_origin: 'gocd',
              is_source_a_file: true,
              source: 'linux_x11_64_debug',
              destination: 'templates',
              pipeline: pipeline_name,
              stage: 'templateStage',
              job: 'linuxJob',
            },
            if disable_web == false then
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'webassembly_debug.zip',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: 'webJob',
              },
            if disable_web == false then
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'webassembly_release.zip',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: 'webJob',
              },
            if disable_osx == false then
              {
                type: 'fetch',
                artifact_origin: 'gocd',
                is_source_a_file: true,
                source: 'osx.zip',
                destination: 'templates',
                pipeline: pipeline_name,
                stage: 'templateStage',
                job: 'osxJob',
              } else null,
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

local godot_tools_pipeline_export(pipeline_name='',
                                  pipeline_dependency='',
                                  itchio_login='',
                                  gocd_group='',
                                  godot_status='',
                                  gocd_project_folder='',
                                  groups_git='',
                                  groups_branch='',
                                  gocd_build_project_material=[],
                                  gocd_material_dependencies=[]) =
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
            name: 'windowsJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'export_windows',
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
                  'rm -rf templates && unzip "godot.templates.tpz" && export VERSION="`cat templates/version.txt`" && export TEMPLATEDIR=".local/share/godot/templates/$VERSION" && export BASEDIR="`pwd`" && rm -rf "$TEMPLATEDIR" && mkdir -p "$TEMPLATEDIR" && cd "$TEMPLATEDIR" && mv $BASEDIR/templates/* . && ln server_* "$BASEDIR/templates/"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -rf export_windows && mkdir export_windows && chmod +x godot_server.x11.opt.tools.64 && HOME="`pwd`" ./godot_server.x11.opt.tools.64 --export "Windows Desktop" "`pwd`"/export_windows/v_sekai_windows.exe --path g -v',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
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
          {
            name: 'linuxDesktopJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'export_linux_x11',
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
                  'rm -rf export_linux_x11 && mkdir export_linux_x11 && chmod +x godot_server.x11.opt.tools.64 && HOME="`pwd`" ./godot_server.x11.opt.tools.64 --export "Linux/X11" "`pwd`"/export_linux_x11/v_sekai_linux_x11 --path g -v',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
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
          {
            name: 'linuxServerJob',
            resources: [
              'linux',
              'mingw5',
            ],
            artifacts: [
              {
                type: 'build',
                source: 'export_linux_server',
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
                  'rm -rf export_linux_server && mkdir export_linux_server && chmod +x godot_server.x11.opt.tools.64 && HOME="`pwd`" ./godot_server.x11.opt.tools.64 --export "Linux/Server" "`pwd`"/export_linux_server/v_sekai_linux_server --path g -v',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'rm -f export_linux_server/*.so',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
        ],
      },
      {
        name: 'uploadStage',
        clean_workspace: false,
        jobs: [
          {
            name: 'windowsJob',
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
                job: 'windowsJob',
                is_source_a_file: false,
                source: 'export_windows',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push export_windows $ITCHIO_LOGIN:windows-master --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
          {
            name: 'linuxDesktopJob',
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
                job: 'linuxDesktopJob',
                is_source_a_file: false,
                source: 'export_linux_x11',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push export_linux_x11 $ITCHIO_LOGIN:x11-master --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
          {
            name: 'linuxServerJob',
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
                job: 'linuxServerJob',
                is_source_a_file: false,
                source: 'export_linux_server',
                destination: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'butler push export_linux_server $ITCHIO_LOGIN:server-master --userversion $GO_PIPELINE_LABEL-`date --iso=seconds --utc`',
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

local godot_template_sandbox = 'godot-template-sandbox';
local godot_template_groups_editor = 'godot-template-groups';
local godot_template_groups_export = 'production-groups-release-export';
local godot_template = [godot_template_groups_editor, godot_template_groups_export];
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
    linux_app_description='Godot Game Engine by Groups',
    linux_app_server_description='Godot Game Engine Server by Groups',
    disable_server=false,
    disable_web=true,
    disable_osx=true,
#    godot_modules_git='https://github.com/godot-extended-libraries/godot-modules-fire.git',
#    godot_modules_branch='master',
  )),
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
      ]
    )
  ),
}
