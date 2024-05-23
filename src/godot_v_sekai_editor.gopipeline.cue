environment_variables: [{
	name:  "GODOT_STATUS"
	value: "groups-4.3.0"
}]
group:          "gamma"
label_template: "groups-4.3.0.${godot_sandbox[:8]}.${COUNT}"
materials: [{
	branch:      "groups-4.3"
	destination: "g"
	name:        "godot_sandbox"
	type:        "git"
	url:         "https://github.com/V-Sekai/godot.git"
}]
name: "godot-groups"
stages: [{
	jobs: [
		{
			artifacts: [{
				destination: ""
				source:      "g/bin/godot.windows.editor.double.x86_64.llvm.exe"
				type:        "build"
			}]
			name: "windows_job"
			resources: ["mingw5", "linux"]
			tasks: [{
				arguments: ["-c", "sed -i \"/^status =/s/=.*/= \\\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\\"/\" version.py"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}, {
				arguments: ["-c", "mkdir -p ../.cicd_cache && PATH=/opt/llvm-mingw/bin:$PATH SCONS_CACHE=../.cicd_cache scons werror=no module_mvsqlite=off module_desync=off platform=windows target=editor use_lto=no precision=double use_mingw=yes use_llvm=yes use_thinlto=no warnings=no LINKFLAGS=-Wl,-pdb= CCFLAGS='-Wall -Wno-tautological-compare -g -gcodeview' debug_symbols=no"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}]
		}, {
			artifacts: [{
				destination: ""
				source:      "g/bin/godot.linuxbsd.editor.double.x86_64.llvm"
				type:        "build"
			}]
			name: "linux_job"
			resources: ["mingw5", "linux"]
			tasks: [{
				arguments: ["-c", "sed -i \"/^status =/s/=.*/= \\\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\\"/\" version.py"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}, {
				arguments: ["-c", "mkdir -p ../.cicd_cache && SCONS_CACHE=../.cicd_cache module_mvsqlite=off module_desync=off scons werror=no platform=linuxbsd target=editor use_lto=no precision=double use_static_cpp=yes use_llvm=yes builtin_freetype=yes"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}]
		}, {
			artifacts: [{
				destination: ""
				source:      "g/bin/godot.web.template_release.double.wasm32.nothreads.zip"
				type:        "build"
			}]
			name: "web_job"
			resources: ["mingw5", "linux"]
			tasks: [{
				arguments: ["-c", "sed -i \"/^status =/s/=.*/= \\\"$GODOT_STATUS.$GO_PIPELINE_COUNTER\\\"/\" version.py"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}, {
				arguments: ["-c", "source /opt/emsdk/emsdk_env.sh && mkdir -p ../.cicd_cache && SCONS_CACHE=../.cicd_cache EM_CACHE=/tmp scons module_mvsqlite=off module_desync=off werror=no platform=web target=template_release use_lto=no optimize=speed use_llvm=yes threads=no precision=double builtin_freetype=yes initial_memory=256 CCFLAGS='-fno-stack-protector -fno-exceptions'"]
				command:           "/bin/bash"
				type:              "exec"
				working_directory: "g"
			}]
		},
	]
	name: "defaultStage"
}, {
	jobs: [{
		artifacts: [{
			destination: ""
			source:      "g/bin/windows_debug_x86_64.exe"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/windows_release_x86_64.exe"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/version.txt"
			type:        "build"
		}]
		name: "windows_job"
		resources: ["mingw5", "linux"]
		tasks: [{
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "windows_job"
			pipeline:         "godot-groups"
			source:           "godot.windows.editor.double.x86_64.llvm.exe"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "sed -i \"/^status =/s/=.*/= \"$GODOT_STATUS.$GO_PIPELINE_COUNTER\"/\" version.py"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "windows_job"
			pipeline:         "godot-groups"
			source:           "godot.windows.editor.double.x86_64.llvm.exe"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "ls"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "cp bin/godot.windows.editor.double.x86_64.llvm.exe bin/windows_debug_x86_64.exe && cp bin/godot.windows.editor.double.x86_64.llvm.exe bin/windows_release_x86_64.exe && mingw-strip --strip-debug bin/windows_release_x86_64.exe"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "eval `sed -e \"s/ = /=/\" version.py` && declare \"_tmp$patch=.$patch\" \"_tmp0=\" \"_tmp=_tmp$patch\" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}]
	}, {
		artifacts: [{
			destination: ""
			source:      "g/bin/linux_debug.x86_64"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/linux_release.x86_64"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/version.txt"
			type:        "build"
		}]
		name: "linux_job"
		resources: ["mingw5", "linux"]
		tasks: [{
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "linux_job"
			pipeline:         "godot-groups"
			source:           "godot.linuxbsd.editor.double.x86_64.llvm"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "sed -i \"/^status =/s/=.*/= \"$GODOT_STATUS.$GO_PIPELINE_COUNTER\"/\" version.py"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "linux_job"
			pipeline:         "godot-groups"
			source:           "godot.linuxbsd.editor.double.x86_64.llvm"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "ls"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "cp bin/godot.linuxbsd.editor.double.x86_64.llvm bin/linux_debug.x86_64 && cp bin/godot.linuxbsd.editor.double.x86_64.llvm bin/linux_release.x86_64 && strip --strip-debug bin/linux_release.x86_64"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "eval `sed -e \"s/ = /=/\" version.py` && declare \"_tmp$patch=.$patch\" \"_tmp0=\" \"_tmp=_tmp$patch\" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}]
	}, {
		artifacts: [{
			destination: ""
			source:      "g/bin/web_nothreads_debug.zip"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/web_nothreads_release.zip"
			type:        "build"
		}, {
			destination: ""
			source:      "g/bin/version.txt"
			type:        "build"
		}]
		name: "web_job"
		resources: ["mingw5", "linux"]
		tasks: [{
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "web_job"
			pipeline:         "godot-groups"
			source:           "godot.web.template_release.double.wasm32.nothreads.zip"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "sed -i \"/^status =/s/=.*/= \"$GODOT_STATUS.$GO_PIPELINE_COUNTER\"/\" version.py"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			artifact_origin:  "gocd"
			destination:      "g/bin/"
			is_source_a_file: true
			job:              "web_job"
			pipeline:         "godot-groups"
			source:           "godot.web.template_release.double.wasm32.nothreads.zip"
			stage:            "defaultStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "ls"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "cp bin/godot.web.template_release.double.wasm32.nothreads.zip bin/web_nothreads_debug.zip && cp bin/godot.web.template_release.double.wasm32.nothreads.zip bin/web_nothreads_release.zip"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}, {
			arguments: ["-c", "eval `sed -e \"s/ = /=/\" version.py` && declare \"_tmp$patch=.$patch\" \"_tmp0=\" \"_tmp=_tmp$patch\" && echo $major.$minor${!_tmp}.$GODOT_STATUS.$GO_PIPELINE_COUNTER > bin/version.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: "g"
		}]
	}]
	name: "templateStage"
}, {
	jobs: [{
		artifacts: [{
			destination: ""
			source:      "godot.templates.tpz"
			type:        "build"
		}]
		name: "defaultJob"
		resources: ["linux", "mingw5"]
		tasks: [{
			arguments: ["-c", "rm -rf templates"]
			command: "/bin/bash"
			type:    "exec"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "windows_job"
			pipeline:         "godot-groups"
			source:           "version.txt"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "windows_job"
			pipeline:         "godot-groups"
			source:           "windows_debug_x86_64.exe"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "windows_job"
			pipeline:         "godot-groups"
			source:           "windows_release_x86_64.exe"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "linux_job"
			pipeline:         "godot-groups"
			source:           "linux_debug.x86_64"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "linux_job"
			pipeline:         "godot-groups"
			source:           "linux_release.x86_64"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "web_job"
			pipeline:         "godot-groups"
			source:           "web_nothreads_debug.zip"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			artifact_origin:  "gocd"
			destination:      "templates"
			is_source_a_file: true
			job:              "web_job"
			pipeline:         "godot-groups"
			source:           "web_nothreads_release.zip"
			stage:            "templateStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "rm -rf godot.templates.tpz"]
			command: "/bin/bash"
			type:    "exec"
		}, {
			arguments: ["-c", "zip -1 godot.templates.tpz templates/*"]
			command: "/bin/bash"
			type:    "exec"
		}]
	}]
	name: "templateZipStage"
}]
timer: {
	only_on_changes: true
	spec:            "* * * * * ?"
}
