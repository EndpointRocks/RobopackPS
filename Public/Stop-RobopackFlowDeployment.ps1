function Stop-RobopackFlowDeployment {
    <#
    .SYNOPSIS
    Stops deployment processing.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/deployment/{id}/stop.
    Stops processing of a deployment in Robopack. This does not stop Intune
    from deploying the app based on assignments already created by Robopack,
    but it prevents Robopack from moving to the next wave.

    .PARAMETER DeploymentId
    ID of target deployment.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Stop-RobopackFlowDeployment -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Stops deployment processing for the specified deployment.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId/stop"

    Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}