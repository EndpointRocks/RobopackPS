function Resolve-RobopackPath {
    <#
    .SYNOPSIS
    Ensures a path exists and returns its resolved full path.

    .DESCRIPTION
    Checks whether the specified path exists, creates it as a directory when it
    is missing, and returns the resolved absolute filesystem path.

    .PARAMETER Path
    The filesystem path to validate, create if needed, and resolve.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }

    return (Resolve-Path $Path).Path
}
