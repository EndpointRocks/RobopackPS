function Initialize-RobopackPackage {
    <#
    .SYNOPSIS
    Creates a local package scaffold.

    .DESCRIPTION
    Initializes a local Robopack package folder with a minimal structure:
    - metadata.json
    - Content\
    - Scripts\\Install.ps1
    - Scripts\\Uninstall.ps1
    - Scripts\\Detect.ps1

    This command only prepares files on disk. It does not call the Robopack API.
    Typical workflow:
    1) Initialize-RobopackPackage
    2) Test-RobopackPackage
    3) Publish-RobopackPackage

    .PARAMETER Name
    Package name used for folder name and initial metadata values.

    .PARAMETER Path
    Base directory where the package folder is created.

    .PARAMETER Msi
    Creates metadata scaffold with sourceType `msi`.
    If no type switch is specified, `msi` is used by default.
    For MSI auto-generation in Robopack, leave install/uninstall commands and
    detection rules unset in metadata so Robopack can infer them after upload.

    .PARAMETER Zip
    Creates metadata scaffold with sourceType `zip`.
    Adds command placeholders you should replace for your package.

    .PARAMETER Exe
    Creates metadata scaffold with sourceType `exe`.
    Adds command and detection rule placeholders you should replace for your package.

    .EXAMPLE
    Initialize-RobopackPackage -Name "MyApp" -Path "C:\Packages" -Msi
    Creates C:\Packages\MyApp with starter scripts, a Content folder, and metadata.json.

    .EXAMPLE
    Initialize-RobopackPackage -Name "MyApp" -Path "C:\Packages" -Zip
    Creates scaffold metadata preconfigured for zip source type.

    .EXAMPLE
    Initialize-RobopackPackage -Name "MyApp" -Path "C:\Packages" -Exe
    Creates scaffold metadata preconfigured for exe source type.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [switch]$Msi,

        [Parameter()]
        [switch]$Zip,

        [Parameter()]
        [switch]$Exe
    )

    $selectedTypeCount = @($Msi, $Zip, $Exe | Where-Object { $_ }).Count
    if ($selectedTypeCount -gt 1) {
        throw "Specify only one source type switch: -Msi, -Zip, or -Exe."
    }

    $sourceType = "msi"
    if ($Zip) { $sourceType = "zip" }
    elseif ($Exe) { $sourceType = "exe" }
    elseif ($Msi) { $sourceType = "msi" }

    $Path = Resolve-RobopackPath -Path $Path
    $PackagePath = Join-Path $Path $Name

    New-Item -ItemType Directory -Path $PackagePath | Out-Null
    New-Item -ItemType Directory -Path "$PackagePath\Content" | Out-Null
    New-Item -ItemType Directory -Path "$PackagePath\Scripts" | Out-Null

    $metadata = @{
        name       = "$Name 1.0.0"
        sourceType = $sourceType
    }

    switch ($sourceType) {
        "msi" {
            # Keep MSI scaffold minimal so Robopack can auto-generate install/uninstall/detection when possible.
        }
        "zip" {
            $metadata.publisher = "Your Publisher"
            $metadata.version = "1.0.0"
            $metadata.installCommand = "TODO: set ZIP install command"
            $metadata.uninstallCommand = ""
            $metadata.userContext = $false
        }
        "exe" {
            $metadata.publisher = "Your Publisher"
            $metadata.version = "1.0.0"
            $metadata.installCommand = "$Name.exe /S"
            $metadata.uninstallCommand = ""
            $metadata.userContext = $false
            $metadata.detectionRules = @(
                @{
                    type = "file"
                    path = "%ProgramFiles%\\Vendor\\$Name"
                    fileName = "$Name.exe"
                    is32Bit = $false
                    operator = 0
                    targetVersion = "1.0.0"
                    description = "TODO: Update EXE detection path/file/version for your app"
                }
            )
        }
    }

    $metadata | ConvertTo-Json -Depth 6 | Out-File "$PackagePath\metadata.json"

@"
Write-Output 'Install script placeholder'
"@ | Out-File "$PackagePath\Scripts\Install.ps1"

@"
Write-Output 'Uninstall script placeholder'
"@ | Out-File "$PackagePath\Scripts\Uninstall.ps1"

@"
Write-Output 'Detection script placeholder'
"@ | Out-File "$PackagePath\Scripts\Detect.ps1"

    Write-Verbose "New Robopack package created at: $PackagePath"
    return $PackagePath
}
