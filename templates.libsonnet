{

build_docker_server(
  pipeline_name='',
  pipeline_dependency='',
  gocd_group='',
  godot_status='',
  docker_groups_git='',
  docker_groups_branch='',
  docker_groups_dir='',
  docker_repo_groups_server='',
  server_export_info={},
      )::
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
                  'ls "g/' + docker_groups_dir + '"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'chmod 01777 "g/' + docker_groups_dir + '/' + server_export_info.export_directory + '"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'chmod a+x g/"' + docker_groups_dir + '/' + server_export_info.export_directory + '/' + server_export_info.export_executable + '"',
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
                  ' g/"' + docker_groups_dir + '"',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
              {
                type: 'exec',
                arguments: [
                  '-c',
                  'docker push "' + docker_repo_groups_server + ':$GO_PIPELINE_LABEL"',
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
  },
    simple_docker_job(pipeline_name='',
                        gocd_group='',
                        docker_repo_variable='',
                        docker_git='',
                        docker_branch='',
                        docker_dir='')::
  {
    name: pipeline_name,
    group: gocd_group,
    label_template: pipeline_name + '_${' + pipeline_name + '_git[:8]}.${COUNT}',
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
                  'set -x' +
                  '; docker build -t "' + docker_repo_variable + ':$GO_PIPELINE_LABEL"' +
                  ' "g/' + docker_dir + '" && docker push "' + docker_repo_variable + ':$GO_PIPELINE_LABEL"' +
                  ' && echo "' + docker_repo_variable + ':$GO_PIPELINE_LABEL" > docker_image.txt',
                ],
                command: '/bin/bash',
                working_directory: '',
              },
            ],
          },
        ],
      },
    ],
  }
  }