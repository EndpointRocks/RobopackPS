function Get-RobopackFlowWaveDetails {
    <#
    .SYNOPSIS
    Gets details for a flow wave.

    .DESCRIPTION
    Retrieves details for a specific flow wave from the Robopack API endpoint:
    /v1/flow/wave/{waveId}

    .PARAMETER WaveId
    The ID of the wave to retrieve.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackFlowWaveDetails -WaveId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves details for the specified wave.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $WaveId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/wave/$WaveId"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
