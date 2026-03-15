function Remove-RobopackFlow {
    <#
    .SYNOPSIS
    Deletes a deployment flow.

    .DESCRIPTION
    Calls Robopack API endpoint DELETE /v1/flow/{id}.
    Optionally deletes the app from any Intune tenants as well.

    .PARAMETER FlowId
    ID of deployment flow to delete.

    .PARAMETER DeleteFromIntune
    If specified, also deletes the app from Intune tenants. Defaults to false (flow only removed from Robopack).

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Remove-RobopackFlow -ApiKey $key -FlowId "guid"

    .EXAMPLE
    Remove-RobopackFlow -ApiKey $key -FlowId "guid" -DeleteFromIntune
    Deletes the flow and removes the app from Intune as well.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [Guid] $FlowId,

        [switch] $DeleteFromIntune,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $target = "Flow $FlowId"
    if ($DeleteFromIntune) {
        $target = "$target (including Intune app content)"
    }

    if (-not $PSCmdlet.ShouldProcess($target, "Delete deployment flow")) {
        return
    }

    $query = @{}
    if ($DeleteFromIntune) {
        $query.deleteFromIntune = $true
    }

    return Invoke-RobopackApi `
        -Method DELETE `
        -Endpoint "flow/$FlowId" `
        -Query $query `
        -ApiKey $ApiKey
}
