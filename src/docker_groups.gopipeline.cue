group:          "charlie"
label_template: "${groups-export_pipeline_dependency}.${COUNT}"
materials: [{
	branch:      "master"
	destination: "g"
	name:        "docker_groups_git"
	type:        "git"
	url:         "https://github.com/V-Sekai/docker-groups.git"
}, {
	ignore_for_scheduling: false
	name:                  "groups-export_pipeline_dependency"
	pipeline:              "groups-export"
	stage:                 "exportStage"
	type:                  "dependency"
}]
name: "docker-groups"
stages: [{
	clean_workspace: false
	fetch_materials: true
	jobs: [{
		artifacts: [{
			destination: ""
			source:      "docker_image.txt"
			type:        "build"
		}]
		name: "dockerJob"
		resources: [
			"dind",
		]
		tasks: [{
			artifact_origin:  "gocd"
			destination:      "g/groups_server"
			is_source_a_file: false
			job:              "linux_job"
			pipeline:         "groups-export"
			source:           "export_linuxbsd"
			stage:            "exportStage"
			type:             "fetch"
		}, {
			arguments: ["-c", "ls \"g/groups_server\""]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}, {
			arguments: ["-c", "chmod 01777 \"g/groups_server/export_linuxbsd\""]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}, {
			arguments: ["-c", "chmod a+x g/\"groups_server/export_linuxbsd/v_sekai_linuxbsd\""]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}, {
			arguments: ["-c", "docker build -t groupsinfra/groups-server:$GO_PIPELINE_LABEL --build-arg SERVER_EXPORT=\"export_linuxbsd\" --build-arg GODOT_REVISION=\"master\" --build-arg USER=1234 --build-arg HOME=/server --build-arg GROUPS_REVISION=\"$GO_PIPELINE_LABEL\" g/\"groups_server\""]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}, {
			arguments: ["-c", "docker push \"groupsinfra/groups-server:$GO_PIPELINE_LABEL\""]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}, {
			arguments: ["-c", "echo \"groupsinfra/groups-server:$GO_PIPELINE_LABEL\" > docker_image.txt"]
			command:           "/bin/bash"
			type:              "exec"
			working_directory: ""
		}]
	}]
	name: "buildPushStage"
}]
