{
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