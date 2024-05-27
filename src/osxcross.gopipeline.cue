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
			artifacts: [{
				destination: ""
				source:      "o/target"
				type:        "build"
			}]
			name: "linux_job"
			resources: ["mingw5", "linux"]
			tasks: [
				{
					arguments: ["-c", "curl -L https://github.com/V-Sekai-fire/osxcross/releases/download/v20240525/MacOSX14.2.sdk.tar.xz -o tarballs/MacOSX14.2.sdk.tar.xz"]
					command:           "/bin/bash"
					type:              "exec"
					working_directory: "o"
				},
				{
					"arguments": [
						"-c",
						"export UNATTENDED=1 && CLANG_VERSION=16.0.0 ENABLE_CLANG_INSTALL=1 INSTALLPREFIX=target ./build_apple_clang.sh && export PATH=$PATH:target/bin && ./build.sh && DISABLE_PARALLEL_ARCH_BUILD=1 ./build_compiler_rt.sh"
					],
					"command": "/bin/bash",
					"type": "exec",
					"working_directory": "o"
				}
			]
		},
	]
}]

