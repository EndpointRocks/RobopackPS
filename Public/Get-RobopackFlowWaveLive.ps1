function Get-RobopackFlowWaveLive {
    <#
    .SYNOPSIS
    Gets live status for a flow wave.

    .DESCRIPTION
    Retrieves live status data for a specific flow wave from the Robopack API endpoint:
    /v1/flow/wave/{waveId}/live

    .PARAMETER WaveId
    The ID of the wave to retrieve live data for.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackFlowWaveLive -WaveId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves live status for the specified wave.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $WaveId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow/wave/$WaveId/live"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
