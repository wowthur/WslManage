Remove-Module WslManage
Import-Module .\WslManage.psm1

$tests = @(
    "Get-Wsl", 
    "Get-Wsl -DistributionName UbuntuTest",
    #"Add-Wsl -Location ~\Downloads\ubuntu-base-20.04-base-amd64.tar.gz -DistributionName UbuntuTest",
    "Add-Wsl -Location http://cdimage.ubuntu.com/ubuntu-base/releases/focal/release/ubuntu-base-20.04-base-amd64.tar.gz -DistributionName UbuntuTest"
    "Start-Wsl -DistributionName UbuntuTest"
    "Remove-Wsl -DistributionName UbuntuTest"
    )

$InformationPreference = "Continue"
$DebugPreference = "Continue"

$tests | ForEach-Object {
    Write-Information "Test: $_"
    Invoke-Expression -Command $_ -ErrorAction "Continue" -WarningAction "Continue"
}