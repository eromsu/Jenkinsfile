@Library('AutomateEverything@0.7')
import com.cisco.jenkins.*
import com.cisco.docker.*
import java.text.SimpleDateFormat

def dock   = new Docker(this)
//def utils  = new Utils(this)

// Disable concurent builds
properties([
    disableConcurrentBuilds()
])

// ATAG information
def atagCredentialsId = "345c79bc-9def-4981-94b5-d8190fdd2304"
def atagGitBranch     = "master"
def atagGitRepoUrl    = "https://wwwin-github.cisco.com/AS-Internal/ACI-Automate-Build-Test"

// DAFE information
def dafeCredentialsId = "345c79bc-9def-4981-94b5-d8190fdd2304"
def dafeGitBranch     = "devdafeansible"
def dafeGitRepoUrl    = "https://wwwin-github.cisco.com/AS-Community/DAFE"

// Ansible Tool Kit inforation
def ansibleWorking = false
def ansibleCredentialsId = "345c79bc-9def-4981-94b5-d8190fdd2304"
def ansibleGitBranch     = "master"
def ansibleGitRepoUrl    = "https://wwwin-github.cisco.com/moskrive/ansible-aci-simulator-tools"
def ansibleBaseInventory = "http://cx-emear-tools-stats.cisco.com/automation/jenkins-aar2-ansible-inventory.yaml"

// CXTA / CXTA information
def cxtaImage = "dockerhub.cisco.com/cxta-docker/cxta:19.7"

// ACI Simulator information
def sim_vm_version = "4.1.1k"
def sim_vm_ip = "10.53.38.125"
def sim_vm_mask = "24"
def sim_vm_gw = "10.53.38.1"
def sim_vm_passwd = "cisco123"

// Misc Variables
def build = buildId() // Unique buildId based upon the Jenkins Job & Build Number
build = build.toLowerCase()
def email_rec = "eubebe@cisco.com"

node() {
    def dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
    def date = new Date()
    def startDate = dateFormat.format(date)

    try {
        stage('Checkout') {
            // // ATAG
            // dir('atag') {
            //     checkout scm
            // }
            // ATAG
            dir('atag') {
                checkout([$class: 'GitSCM',
                branches: [[name: "*/${atagGitBranch}"]],
                userRemoteConfigs: [[credentialsId: "${atagCredentialsId}",
                                    url: "${atagGitRepoUrl}"]]
                ])
            }    
            // DAFE
            dir('dafe') {
                checkout([$class: 'GitSCM', 
                branches: [[name: "*/${dafeGitBranch}"]], 
                userRemoteConfigs: [[credentialsId: "${dafeCredentialsId}", 
                                    url: "${dafeGitRepoUrl}"]]
                ])
            }
            // Ansible Toolkit
            dir('ansible') {
                // Checkout scripts and build ansible tools container
                checkout([$class: 'GitSCM', 
                branches: [[name: "*/${ansibleGitBranch}"]], 
                userRemoteConfigs: [[credentialsId: "${ansibleCredentialsId}", 
                                    url: "${ansibleGitRepoUrl}"]]
                ])
            }
        }
        stage('Build Container Images') {
            // Build ATAG/DAFE container
            sh "cp atag/atag/environments/Dockerfile . || true"
            def atagImage = docker.build("atag:latest")
            sh "rm Dockerfile || true"

            // Build Ansible Toolkit container
            dir('ansible') {
                def ansibleImage = docker.build("atag_ansible:latest")
            }
        }
        stage('Starting Containers') {
            // Start ATAG/DAFE container
            echo "Starting ATAG / DAFE container"
            sh "docker run --name atag_${build} atag:latest tail -f /dev/null &"

            // Start Ansible container
            echo "Starting Ansible Toolkit"
            dir('ansible') {
                sh "docker run --name ansible_${build} atag_ansible:latest tail -f /dev/null &"

                // Retrieve base Ansible inventory and add test specific arguments
                sh "curl -o inventory.yaml -k ${ansibleBaseInventory}"
                sh "echo \"    vm_name: jenkins-acisim-${sim_vm_version}\" >> inventory.yaml"
                sh "echo \"    vm_ip: ${sim_vm_ip}\" >> inventory.yaml"
                sh "echo \"    vm_mask: ${sim_vm_mask}\" >> inventory.yaml"
                sh "echo \"    vm_gw: ${sim_vm_gw}\" >> inventory.yaml"
                sh "echo \"    vm_passwd: ${sim_vm_passwd}\" >> inventory.yaml"

                // Copy Ansible Inventory file to container and remove it locally afterwards
                sh "docker cp inventory.yaml ansible_${build}:/ansible/inventory.yaml"
                sh "rm inventory.yaml || true"
            }

            // CXTA
            echo "Starting CXTA"
            cxtaImage = docker.image("${cxtaImage}")
            cxtaImage.pull()
            cxtaContainer = cxtaImage.run("--name cxta_${build}", "tail -f /dev/null")
            echo "CXTA Container ID = ${cxtaContainer.id}"
 
        }
        stage('Start ACI Simulator') {
            // Verify ACI Simulator availability
            echo "Verifying availability of ACI Simulator"
            ansibleExec = sh (script: "docker exec -t ansible_${build} /bin/bash -c \"cd /ansible && ansible-playbook -i inventory.yaml verify_aci_sim_available.yaml\"", returnStatus: true) 
            if (ansibleExec != 0) {
                error('Failure, ACI Simulator not available')
            } else {
                ansibleWorking = true
            }

            // Start ACI Simulator
            echo "Staring ACI Simulator"
            sh "docker exec -t ansible_${build} /bin/bash -c \"cd /ansible && ansible-playbook -i inventory.yaml start_aci_simulator.yaml\""

            // Allow ACI simulator's network stack to come up
            echo "Sleep, while ACI Simulator initializes"
            sleep 200

            // Clear ARP entry for ACI simulator on gateway
            sh "docker exec -t ansible_${build} /bin/bash -c \"cd /ansible && ansible-playbook -i inventory.yaml clear_aci_simulator_arp_entry.yaml\"" 

            // Checking if ACI Simulator are reachable
            echo "Checking if ACI Simulator is reachable"
            simAlive = sh (script: "ping -c 5 ${sim_vm_ip}", returnStatus: true)
            echo "Simulator is ${simAlive == 0 ? 'reachable': 'NOT reachable'}"
            if (simAlive != 0) {
                error('Failling, as ACI Simulator is not reachable via ping')
            }
        }
        stage('Configure ACI Simulator') {
            // Run DAFE
            echo "Running DAFE"
            sh "docker exec -t atag_${build} /bin/bash -c \"cp /ATAG/test/integration-acisim/dafe-aci_credentials.py /DAFE/aci_credentials.py\" || true"
            sh "docker exec -t atag_${build} /bin/bash -c \"cd /DAFE && python aci_deploy_fabric_from_excel.py -f\""

            // Allow ACI simulator to register nodes, etc.
            echo "Sleep, while ACI Simulator initializes configuration"
            sleep 120
        }
        stage('Generate CXTA Test Suite') {
            // Running ATAG
            echo "Running ATAG"
            sh "docker exec -t atag_${build} /bin/bash -c \"cd /ATAG && python generate_aci_tests.py -f -c test/integration-acisim/atag_config.yaml --incognito\""
            sh "docker exec -t atag_${build} /bin/bash -c \"cd /ATAG && tar cvf aci_tests.tar aci_tests.robot aci_tests_testbed.yaml\""
        }
        stage('Execute CXTA Test Suite') {
            def homeDir    = "/home/cisco/cxta"
            def outputsDir = "${homeDir}/outputs"

            // Copy test suite to CXTA container
            echo "Copying test suite to CXTA container"
            sh "docker cp atag_${build}:/ATAG/aci_tests.tar ."
            sh "docker cp aci_tests.tar cxta_${build}:${homeDir}/"
            sh "docker exec cxta_${build} /bin/bash -c \"cd ${homeDir} && tar xvf aci_tests.tar\""

            // Running Rasta
            echo "Running CXTA"
            test_results  =    
              sh(script: "docker exec cxta_${build} /bin/bash -lc \"cd ${homeDir} && (robot aci_tests.robot || true) \"; echo \$?",    
              returnStdout: true).trim() 
            echo "${test_results}"
 
            // Publish CXTA results
            echo "Publish Reports"
            ret  = sh (script: "docker exec cxta_${build} /bin/bash -c \"mkdir ${outputsDir} && cd ${homeDir} && cp *.xml *.html ${outputsDir}/ && cd ${outputsDir} && tar cvf ${outputsDir}/output.tar.gz report.html log.html output.xml\"; echo \$?",
                  returnStdout: true).trim()
            sh "docker cp cxta_${build}:${outputsDir}/output.tar.gz ./ || true"
            sh "tar -xvf output.tar.gz || true"    
            step([$class : 'RobotPublisher', outputPath : "${WORKSPACE}", disableArchiveOutput : false, passThreshold : 100.0, unstableThreshold: 90.0, otherFiles: ""])   
        }

    } catch(error) {
        echo "Exception: " + error

        // Overwrite the build result!
        currentBuild.result = 'FAILURE'
    } finally {
        stage('Clean up') {
            // Poweroff simulator
            if (ansibleWorking == true) {
                echo "Powering off ACI Simulator"
                sh "docker exec -t ansible_${build} /bin/bash -c \"cd /ansible; ansible-playbook -i inventory.yaml stop_aci_simulator.yaml\"" 
            }

            // Delete ATAG/DAFE container and container image
            echo "stopping and deleting ATAG / DAFE container"
            sh "docker rm -f atag_${build} || true"
            sh "docker image rm atag:latest || true"

            // Delete Ansible container and container image
            echo "Stopping and deleting Ansible Toolkit "
            sh "docker rm -f ansible_${build} || true"
            sh "docker image rm atag_ansible:latest || true"

            // Deleting CXTA container
            echo "Stopping CXTA container "
            sh "docker rm -f cxta_${build} || true"
        }
        stage('Email Build Results') {
            dir('atag') {
                // Getting author of last commit
                def AUTHOR_LAST_COMMIT= sh (script: "git show -s --pretty=\"%an - %ae\"", returnStdout: true).trim()

                // Send email
                if (!currentBuild.result) {
                    currentBuild.result = 'SUCCESS'
                }
                emailext (
                from: "atag-jenkins@cisco.com",
                attachementsPattern: "output.tar.gz",
                mimeType: 'text/html',
                body: """<p>Branch ${env.BRANCH_NAME}.</p>
                        <p>Author of last commit is ${AUTHOR_LAST_COMMIT}.</p>
                        <p>Jenkins Build completed with status: ${currentBuild.currentResult} for job: ${currentBuild.fullDisplayName}.<br>
                        Check console output at ${env.BUILD_URL}.</p>
                        <p> Tests results are attached.</p>
                    """,
                subject: "${currentBuild.currentResult}: ATAG:${env.BRANCH_NAME}: Jenkins Pipeline completed. Job ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                to: "${email_rec}"
                )
            }
        }
    }
}
