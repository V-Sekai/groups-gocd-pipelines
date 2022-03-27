{
  groups_gdextension_plugins: {
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
            'rm -f demo/addons/godot-openvr/bin/win64/libgodot_openvr*.dll',
          ],
          extra_commands: [
            'cp -a openvr/bin/win64/openvr_api.dll demo/addons/godot-openvr/bin/win64/openvr_api.dll',
            'cp -a openvr/bin/win64/openvr_api.dll.sig demo/addons/godot-openvr/bin/win64/openvr_api.dll.sig',
            'cp -a openvr/bin/win64/openvr_api.pdb demo/addons/godot-openvr/bin/win64/openvr_api.pdb',
            'cd demo/addons/godot-openvr/bin/win64 && mv libgodot_openvr.dll libgodot_openvr.dbg.dll && mingw-strip --strip-debug -o libgodot_openvr.dll libgodot_openvr.dbg.dll',
          ],
          //install_task: ["mv libGodotSpeech.dll g/addons/godot_speech/bin/libGodotSpeech.dll"],
        },
        web: {
          artifacts: [
          ],
          output_artifacts: [
          ],
          debug_artifacts: [],
          scons_arguments: '',
          environment_variables: [],
          prepare_commands: [],
          extra_commands: [],
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
  },
}
