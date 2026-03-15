function New-RobopackFlow {
    <#
    .SYNOPSIS
    Creates a new deployment flow.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/create.
    If PatchGroupId is provided, the flow inherits waves/settings from that patch group.

    .PARAMETER PatchGroupId
    Optional ID of patch group to add the new flow to.

    .PARAMETER AppId
    Optional ID of instant app to create flow for. Mutually exclusive with PackageId.

    .PARAMETER Scope
    Optional scope for the new flow. Allowed values: 1, 2, 4.
    Note: For package-based flows (when PackageId is used), the API may ignore this value
    and normalize scope to Machine.

    .PARAMETER PackageId
    Optional ID of package to create flow for. Mutually exclusive with AppId.

    .PARAMETER Name
    Optional name of the new flow.

    .PARAMETER Flags
    Optional flow flags bitmask. Values can be combined using addition of bit values
    (for example, 3 = 1 + 2).

    0 - No documented behavior.
    1 - Start new versions automatically.
    2 - On new version, stop current version and start new one.
    4 - Run new version alongside current one.
    8 - No documented behavior.
    16 - Do not remove superseded apps.
    32 - Uninstall previous version when upgrading.
    64 - No documented behavior.
    128 - Create MSIX as Win32, not Line-of-Business (LoB).
    256 - Allow available uninstallation in Company Portal.
    512 - No documented behavior.
    1024 - No documented behavior.
    2048 - No documented behavior.
    4096 - No documented behavior.
    8192 - Use app name instead of flow name for apps in Intune.
    16384 - Radar Tracking Enabled.
    32768 - Match newer versions in detection method.

    .PARAMETER SupersedenceHistoryCount
    Optional number of superseded packages to keep in Intune. Range: 0-8.

    .PARAMETER TemplateId
    Optional ID of script template to use for the flow.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    New-RobopackFlow -ApiKey $key -AppId "guid" -Scope 1 -Name "Chrome Monthly"
    Creates a new deployment flow and returns the created flow identifier/object.

    .EXAMPLE
    New-RobopackFlow -ApiKey $key -PackageId "guid" -Scope 2 -PatchGroupId "guid"
    Creates a new deployment flow from a package and patch group.

    .EXAMPLE
    New-RobopackFlow -ApiKey $key -PackageId "guid" -Flags 1 -Name "Package Flow - Auto Start"
    Creates a package-based flow with flag 1 enabled.

    .EXAMPLE
    New-RobopackFlow -ApiKey $key -PackageId "guid" -Flags 3 -Name "Package Flow - Flags 1 and 2"
    Creates a package-based flow with combined flags 1 and 2 (3 = 1 + 2).

    .EXAMPLE
    New-RobopackFlow -ApiKey $key -PackageId "guid" -Flags 16645 -Name "Package Flow - Common Combined Flags"
    Creates a package-based flow using combined flags 1, 4, 256, and 16384.
    #>
    [CmdletBinding()]
    param(
        [Nullable[Guid]] $PatchGroupId,

        [Nullable[Guid]] $AppId,

        [ValidateSet(1, 2, 4)]
        [int] $Scope,

        [Nullable[Guid]] $PackageId,

        [string] $Name,

        [int] $Flags,

        [ValidateRange(0, 8)]
        [int] $SupersedenceHistoryCount,

        [Nullable[Guid]] $TemplateId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    if ($PSBoundParameters.ContainsKey('AppId') -and $PSBoundParameters.ContainsKey('PackageId')) {
        throw "AppId and PackageId are mutually exclusive. Specify only one of them."
    }

    if ($PSBoundParameters.ContainsKey('PackageId') -and $PSBoundParameters.ContainsKey('Scope')) {
        Write-Warning "Scope may be ignored by the API for package-based flows and normalized to Machine."
    }

    $body = @{}

    if ($PSBoundParameters.ContainsKey('PatchGroupId')) {
        $body.patchGroupId = $PatchGroupId
    }

    if ($PSBoundParameters.ContainsKey('AppId')) {
        $body.appId = $AppId
    }

    if ($PSBoundParameters.ContainsKey('Scope')) {
        $body.scope = $Scope
    }

    if ($PSBoundParameters.ContainsKey('PackageId')) {
        $body.packageId = $PackageId
    }

    if ($PSBoundParameters.ContainsKey('Name')) {
        $body.name = $Name
    }

    if ($PSBoundParameters.ContainsKey('Flags')) {
        $body.flags = $Flags
    }

    if ($PSBoundParameters.ContainsKey('SupersedenceHistoryCount')) {
        $body.supersedenceHistoryCount = $SupersedenceHistoryCount
    }

    if ($PSBoundParameters.ContainsKey('TemplateId')) {
        $body.templateId = $TemplateId
    }

    return Invoke-RobopackApi `
        -Method POST `
        -Endpoint "flow/create" `
        -Body $body `
        -ApiKey $ApiKey
}
