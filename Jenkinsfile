
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Downloading Online Calculator from GitHub'
                checkout scm
            }
        }

        stage('Test Project Files') {
            steps {
                powershell '''
                    if (!(Test-Path "index.html")) {
                        throw "index.html is missing"
                    }

                    if (!(Test-Path "serve.ps1")) {
                        throw "serve.ps1 is missing"
                    }

                    Write-Output "Calculator files verified successfully"
                '''
            }
        }

        stage('Deploy Website') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"

                    $existing = $false
                    try {
                        $check = Invoke-WebRequest `
                            -Uri "http://localhost:8000/" `
                            -TimeoutSec 2 `
                            -UseBasicParsing

                        if ($check.StatusCode -eq 200) {
                            $existing = $true
                            Write-Output "Website is already running"
                        }
                    } catch {
                        Write-Output "Starting calculator website"
                    }

                    if (-not $existing) {
                        $serverFile = Join-Path $PWD "serve.ps1"

                        Start-Process -FilePath "powershell.exe" `
                            -ArgumentList @(
                                "-NoProfile",
                                "-ExecutionPolicy",
                                "Bypass",
                                "-File",
                                "`"$serverFile`""
                            ) `
                            -WindowStyle Hidden

                        Start-Sleep -Seconds 3

                        $check = Invoke-WebRequest `
                            -Uri "http://localhost:8000/" `
                            -TimeoutSec 10 `
                            -UseBasicParsing

                        if ($check.StatusCode -ne 200) {
                            throw "Website deployment failed"
                        }
                    }

                    Write-Output "Website available at http://localhost:8000/"
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Online Calculator deployed'
        }
        failure {
            echo 'FAILED: Check the Jenkins Console Output'
        }
    }
}
