function Start-RobopackFlowDeployment {
    <#
    .SYNOPSIS
    Starts a deployment.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/deployment/{id}/start.
    Starts deployment processing. Uploading the app to Intune runs in the
    background, so deployment status should be checked to determine when the
    operation has completed.

    .PARAMETER DeploymentId
    ID of target deployment.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Start-RobopackFlowDeployment -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Starts processing for the specified deployment.

    .EXAMPLE
    Start-RobopackFlowDeployment -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Wait-RobopackFlowDeploymentStart -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555" -PollIntervalSeconds 15 -TimeoutMinutes 30
    Starts deployment processing and waits for start operation status.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId/start"

    Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}