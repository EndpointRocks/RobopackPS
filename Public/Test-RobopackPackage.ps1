function Test-RobopackPackage {
    <#
    .SYNOPSIS
    Validates the local package folder structure before publish.

    .DESCRIPTION
    Performs a lightweight local preflight check to confirm required package files exist.
    This command is used by Publish-RobopackPackage to fail early before any API calls.

    The validation checks that these files are present:
    - metadata.json
    - Content\ (folder with at least one file)
    - Scripts\Install.ps1
    - Scripts\Uninstall.ps1
    - Scripts\Detect.ps1

    This command does not validate API payload semantics, metadata field correctness,
    or server-side package behavior.

    .PARAMETER Path
    Path to the local package folder.

    .EXAMPLE
    Test-RobopackPackage -Path ".\MyPackage"
    Returns $true when required files exist, otherwise returns $false.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $Path = Resolve-RobopackPath -Path $Path

    $RequiredFiles = @(
        "metadata.json",
        "Scripts\Install.ps1",
        "Scripts\Uninstall.ps1",
        "Scripts\Detect.ps1"
    )

    foreach ($File in $RequiredFiles) {
        $FullPath = Join-Path $Path $File
        if (-not (Test-Path $FullPath)) {
            Write-Warning "Missing required file: $File"
            return $false
        }
    }

    $contentPath = Join-Path $Path "Content"
    if (-not (Test-Path $contentPath -PathType Container)) {
        Write-Warning "Missing required folder: Content"
        return $false
    }

    $contentFiles = Get-ChildItem -Path $contentPath -File -Recurse
    if ($contentFiles.Count -eq 0) {
        Write-Warning "No files found in Content folder. Add installer/content files before publish."
        return $false
    }

    Write-Verbose "Package structure validated successfully."
    return $true
}
