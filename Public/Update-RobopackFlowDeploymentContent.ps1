function Update-RobopackFlowDeploymentContent {
    <#
    .SYNOPSIS
    Starts an app content update for a deployment.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/deployment/{id}/update-content.
    Starts a background task that regenerates the package and updates the app
    content in Intune for any Intune tenants in the deployment.
    Check deployment status to determine when the operation has completed.

    .PARAMETER DeploymentId
    ID of target deployment.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Update-RobopackFlowDeploymentContent -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Starts the background task to update deployment app content.

    .EXAMPLE
    Update-RobopackFlowDeploymentContent -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Wait-RobopackFlowDeploymentContentUpdate -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555" -PollIntervalSeconds 15 -TimeoutMinutes 60
    Starts the update-content task and then waits for completion.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId/update-content"

    Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
