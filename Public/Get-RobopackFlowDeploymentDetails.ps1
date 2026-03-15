function Get-RobopackFlowDeploymentDetails {
    <#
    .SYNOPSIS
    Gets details for a flow deployment.

    .DESCRIPTION
    Retrieves details for a specific flow deployment from the Robopack API endpoint:
    /v1/flow/deployment/{deploymentId}

    .PARAMETER DeploymentId
    The ID of the deployment to retrieve.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackFlowDeploymentDetails -DeploymentId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves details for the specified deployment.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $DeploymentId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/deployment/$DeploymentId"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
