function Add-RobopackFlowDeployment {
    <#
    .SYNOPSIS
    Adds a new deployment to an existing flow.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/{id}/add-deployment.
    Uses a specific package and can optionally start deployment immediately.
    Returns the created deployment ID.

    .PARAMETER FlowId
    ID of the flow to add deployment to.

    .PARAMETER PackageId
    ID of package to use for the new deployment.

    .PARAMETER StartNow
    If specified, the deployment is started after creation.

    .PARAMETER Version
    Optional version override for deployment. If omitted, package version is used.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Add-RobopackFlowDeployment -ApiKey $key -FlowId "guid" -PackageId "guid"

    .EXAMPLE
    Add-RobopackFlowDeployment -ApiKey $key -FlowId "guid" -PackageId "guid" -StartNow $true -Version "1.2.3"
    Adds a deployment, overrides version, and starts it immediately.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Guid] $FlowId,

        [Parameter(Mandatory)]
        [Guid] $PackageId,

        [switch] $StartNow,

        [string] $Version,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $body = @{
        packageId = $PackageId
    }

    if ($StartNow) {
        $body.startNow = $true
    }

    if ($PSBoundParameters.ContainsKey('Version')) {
        $body.version = $Version
    }

    return Invoke-RobopackApi `
        -Method POST `
        -Endpoint "flow/$FlowId/add-deployment" `
        -Body $body `
        -ApiKey $ApiKey
}
