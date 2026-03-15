function Skip-RobopackFlowDeploymentWave {
    <#
    .SYNOPSIS
    Skips to the next deployment wave.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/flow/deployment/{id}/skip-wave.
    Jumps to the next wave in the deployment regardless of current wave
    progress.

    .PARAMETER DeploymentId
    ID of target deployment.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Skip-RobopackFlowDeploymentWave -ApiKey $apiKey -DeploymentId "11111111-2222-3333-4444-555555555555"
    Moves the deployment directly to the next wave.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId/skip-wave"

    Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}