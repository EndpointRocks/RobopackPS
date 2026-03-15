function Get-RobopackFlowDetails {
    <#
    .SYNOPSIS
    Gets details for a deployment flow.

    .DESCRIPTION
    Retrieves details for a specific flow from the Robopack API endpoint:
    /v1/flow/{flowId}

    .PARAMETER FlowId
    The ID of the flow to retrieve.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackFlowDetails -FlowId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves details for the specified flow.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $FlowId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/$FlowId"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
