function Remove-RobopackFlowDeployment {
    <#
    .SYNOPSIS
    Deletes a deployment from a flow.

    .DESCRIPTION
    Calls Robopack API endpoint DELETE /v1/flow/deployment/{id}.
    Optionally deletes the app from any Intune tenants as well.

    .PARAMETER DeploymentId
    ID of target deployment to delete.

    .PARAMETER DeleteFromIntune
    If specified, also deletes the app from Intune tenants. Defaults to false
    (deployment only removed from Robopack).

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Remove-RobopackFlowDeployment -ApiKey $key -DeploymentId "guid"

    .EXAMPLE
    Remove-RobopackFlowDeployment -ApiKey $key -DeploymentId "guid" -DeleteFromIntune
    Deletes the deployment and removes the app from Intune as well.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [Guid] $DeploymentId,

        [switch] $DeleteFromIntune,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $target = "Deployment $DeploymentId"
    if ($DeleteFromIntune) {
        $target = "$target (including Intune app content)"
    }

    if (-not $PSCmdlet.ShouldProcess($target, "Delete deployment")) {
        return
    }

    $query = @{}
    if ($DeleteFromIntune) {
        $query.deleteFromIntune = $true
    }

    return Invoke-RobopackApi `
        -Method DELETE `
        -Endpoint "flow/deployment/$DeploymentId" `
        -Query $query `
        -ApiKey $ApiKey
}
