function Update-RobopackFlowDeploymentStatus {
    <#
    .SYNOPSIS
    Refreshes deployment status.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/deployment/{id}/refresh.
    Refreshes the status of a deployment and updates wave status based on the
    current deployment state in Intune.

    .PARAMETER DeploymentId
    ID of target deployment.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Update-RobopackFlowDeploymentStatus -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Refreshes the status for the specified deployment.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId/refresh"

    Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}