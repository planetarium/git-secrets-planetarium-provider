# Clone the git-secrets repository and run the install.ps1 script
Write-Output "Cloning git-secrets repository..."
$gitSecretsRepo = "https://github.com/awslabs/git-secrets"
git clone $gitSecretsRepo
cd git-secrets
Write-Output "Running install.ps1 from the git-secrets repository..."
.\install.ps1

# Navigate back to the original directory and remove the cloned repository
cd ..
Remove-Item -Recurse -Force git-secrets

# Create planetarium directory and fetch-patterns script
$planetariumDir = "$HOME\.planetarium"
if (-not (Test-Path $planetariumDir)) {
    New-Item -ItemType Directory -Path $planetariumDir
}

$fetchPatternsScriptPath = Join-Path $planetariumDir "fetch-patterns.ps1"
@"
(Invoke-WebRequest -URI  https://raw.githubusercontent.com/planetarium/git-secrets-planetarium-provider/main/patterns.txt).Content
"@ | Out-File $fetchPatternsScriptPath -Encoding utf8

# Make the script executable (this is mostly for bash compatibility)
# If you don't plan to run this from bash, you can skip this step.
icacls $fetchPatternsScriptPath /grant Everyone:RX

git secrets --add-provider --global Powershell $fetchPatternsScriptPath

$gitTemplateDir = "$HOME\.git-templates\git-secrets"
if (-not (Test-Path $gitTemplateDir)) {
    New-Item -ItemType Directory -Path $gitTemplateDir
}

git secrets --install $gitTemplateDir
git config --global init.templateDir $gitTemplateDir

# Prompt user for directory input and install git hooks
$inputDir = Read-Host "Enter the root directory path for installing git-secrets hooks. It will find all subdirectories with a .git folder and install there."
$targetDir = Resolve-Path $inputDir
Write-Output "Running git secrets --install in all .git directories under $targetDir."

Get-ChildItem -Path $targetDir -Recurse -Force -Filter ".git" | ForEach-Object {
    $repoPath = $_.FullName
    Write-Output "Installing in $repoPath"
    git secrets --install (Join-Path $repoPath "..")
}

Write-Output "Configuration completed!"
