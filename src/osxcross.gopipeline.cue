group:          "gamma"
label_template: "osxcross-4.3.0.${osxcross[:8]}.${COUNT}"
materials: [{
	branch:      "master"
	destination: "o"
	name:        "osxcross"
	type:        "git"
	url:         "https://github.com/V-Sekai-fire/osxcross.git"
}]
name: "osxcross"
stages: [{
	name: "defaultStage"
	jobs: [
		{
			name: "linux_job"
			resources: ["mingw5", "linux"]
			tasks: [
				{
					arguments: ["-c", "curl -L https://github.com/V-Sekai-fire/osxcross/releases/download/v20240525/MacOSX14.5.sdk.tar.xz -o tarballs/MacOSX14.5.sdk.tar.xz"]
					command:           "/bin/bash"
					type:              "exec"
					working_directory: "o"
				},
				{
					arguments: ["-c", "curl -L https://github.com/V-Sekai-fire/osxcross/releases/download/v20240525/MacOSX14.5.sdk.tar.xz -o tarballs/MacOSX14.5.sdk.tar.xz"]
					command:           "/bin/bash"
					type:              "exec"
					working_directory: "o"
				},
				{
					arguments: ["-c", "curl -L https://github.com/V-Sekai-fire/osxcross/releases/download/v20240525/MacOSX14.sdk.tar.xz -o tarballs/MacOSX14.sdk.tar.xz"]
					command:           "/bin/bash"
					type:              "exec"
					working_directory: "o"
				},
				{
					arguments: ["-c", "./build.sh"]
					command:           "/bin/bash"
					type:              "exec"
					working_directory: "o"
				},
			]
		},
	]
}]
