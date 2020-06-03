function Get-Wsl {
    param (
        [string] $DistributionName
    )

    $result = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\*

    if ($DistributionName) {
        $result = $result | Where-Object DistributionName -EQ $DistributionName
    }

    $result
}

function Add-Wsl {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Location,

        [Parameter(Mandatory = $true)]
        [string] $DistributionName,

        [string] $Root
    )

    if (Get-Wsl -DistributionName $DistributionName) {
        Write-Warning "$DistributionName is allready taken by another wsl rootfs. Please try a different name or delete existing rootfs with Remove-Wsl"
        exit
    }

    # Write-Debug "Location: $Location"

    if ($Location -match '^https?://.*$') {
        Write-Debug "Downloading from $Location"
        $uri = New-Object -TypeName Uri -ArgumentList $Location
        $filename = $uri.Segments[$uri.Segments.Length - 1]

        if (-not (Test-Path $filename)) {        
            Invoke-RestMethod -Uri $Location -OutFile $filename
        }
    }
    else {
        Write-Error "File location not implemented"
        exit
    }

    if (-not $Root) {
        $Root = "$Env:HOME\wslroot\$DistributionName"
    }

    if (-not (Test-Path $Root)) {
        Write-Information "Creating folder $Root"
        mkdir $Root | Out-Null
    }

    Write-Host "Creating WSL Distro $wsldistroname... "
    wsl --import $DistributionName $Root $filename
}

function Remove-Wsl {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DistributionName
    )

    if (-not (Get-Wsl -DistributionName $DistributionName)) {
        Write-Warning "$DistributionName is not an active wsl rootfs"
        exit
    }

    $dist = Get-Wsl -DistributionName $DistributionName

    wsl --unregister $DistributionName

    Write-Host "Removing rootfs folder $($dist.BasePath)..."
    Remove-Item -Recurse $dist.BasePath
}

function Start-Wsl {
    param(
        [Parameter(Mandatory = $true)]
        [string] $DistributionName,

        [string]
        $Command
    )

    wsl -d $DistributionName -- $Command
}