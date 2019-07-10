pipeline {
    agent {
         label "master"
    }
    options {
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr:'20'))
        ansiColor('xterm')
    }
    stages{
       stage('\u27A1 Preparation') {
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/$DEVBRANCH']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', timeout: 360]],
submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/zunel/hmktest.git']]])
        }
       }
       stage('\u2756 Build and Test in docker container') {
        steps {
           echo "\u001B[34mRunning job: ${env.JOB_NAME} build# ${env.BUILD_ID} started from ${env.JENKINS_URL} on ${env.NODE_NAME}\u001B[0m"
           echo ""
           script {
                    GITHASH =  sh(returnStdout: true, script: "git rev-parse --short=11 HEAD").trim()
                    COMMITER = sh(returnStdout: true, script: "git rev-parse --short=11 HEAD | git log -1 --format='%ae'").trim()
                    currentBuild.displayName = "#${currentBuild.id}-${env.DEVBRANCH}-$GITHASH-$COMMITER"
                    sh """
                    mkdir -p /home/jenkins/export || true
                    sed -i  "s/nametosed/$BUILDBRANCH/g" build.sh
                    sed -i  "s/bld/${currentBuild.id}/g" control
                    sed -i  "s/where/$BUILDBRANCH/g" index.html
                    sed -i  "s/vernumber/1.2.${currentBuild.id}/g" index.html 
                    docker build -t civetweb_build -f Dockerfile.build .
                    docker run -v /home/jenkins/export:/export  --rm  civetweb_build
                    ls -alt /home/jenkins/export
                    """
                  }
           }
         }
        stage('\u273F Build Run docker image') {
                steps {
                echo '\u001B[34mBuilding and Ubuntu image with civetweb deb package installed\u001B[0m'
                script {
                        sh 'export REVISION=`cat /home/jenkins/export/revision.txt` && cp /home/jenkins/export/civetweb_package_${REVISION}.deb . && docker build -t civetweb-${REVISION}.${BUILD_NUMBER} -f Dockerfile.run --build-arg REV=$REVISION .'
               }
           }  
        }
    }
post {
        success {
            step([$class: 'WsCleanup'])
            echo ""
            echo "Will send mail using mutt to attach test reports"
            script {
                  sh """
                      shopt -s globstar
                      echo "civetweb image built succesffully, attached test restults" | mutt  -e 'my_hdr From:me@somewhere.com' -s "Civetweb Ubuntu build" root@localhost -a /home/jenkins/export/**/*.txt
                      echo "Remove docker build image no longer needed"
                      docker rmi civetweb_build
                  """

            }
        }
     }

}
