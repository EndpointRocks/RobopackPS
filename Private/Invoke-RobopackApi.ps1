function Invoke-RobopackApi {
    <#
    .SYNOPSIS
    Sends HTTP requests to the Robopack API.

    .DESCRIPTION
    Builds a Robopack API request from the supplied method, endpoint, query
    parameters, request body, and API key. Supports returning parsed API
    responses or downloading the result directly to a file.

    .PARAMETER Method
    The HTTP method to use for the request.

    .PARAMETER Endpoint
    The Robopack API endpoint relative to /v1.

    .PARAMETER Query
    Optional query string parameters to append to the request.

    .PARAMETER Body
    Optional request body that will be serialized to JSON.

    .PARAMETER OutFile
    Optional path to write the response content to instead of returning the
    parsed response object.

    .PARAMETER ApiKey
    The API key used to authenticate against the Robopack API.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GET','POST','PUT','DELETE')]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Endpoint,

        [Parameter()]
        [hashtable]$Query,

        [Parameter()]
        [hashtable]$Body,

        [Parameter()]
        [string]$OutFile,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    $BaseUrl = "https://api.robopack.com/v1"

    # Normalize endpoint by removing a leading slash to avoid double slashes.
    if ($Endpoint.StartsWith('/')) { $Endpoint = $Endpoint.TrimStart('/') }

    $Headers = @{
        "X-API-Key" = $ApiKey
    }

    # Build query string and skip only null/empty values.
    $qs = $null
    if ($Query) {
        $pairs = foreach ($kv in $Query.GetEnumerator()) {
            if ($null -eq $kv.Value) {
                continue
            }

            $k = [System.Uri]::EscapeDataString([string]$kv.Key)

            if ($kv.Value -is [System.Collections.IEnumerable] -and $kv.Value -isnot [string]) {
                foreach ($item in $kv.Value) {
                    if ($null -eq $item -or $item -eq "") {
                        continue
                    }

                    $v = [string]$item
                    if ($v -eq 'True') { $v = 'true' } elseif ($v -eq 'False') { $v = 'false' }
                    $v = [System.Uri]::EscapeDataString($v)
                    "$k=$v"
                }
                continue
            }

            if ($kv.Value -eq "") {
                continue
            }

            $v = [string]$kv.Value
            if ($v -eq 'True') { $v = 'true' } elseif ($v -eq 'False') { $v = 'false' }
            $v = [System.Uri]::EscapeDataString($v)
            "$k=$v"
        }
        if ($pairs.Count -gt 0) {
            $qs = '?' + ($pairs -join '&')
        }
    }

    $Uri = "$BaseUrl/$Endpoint$qs"

    try {
        if ($OutFile) {
            Invoke-WebRequest -Method $Method -Uri $Uri -Headers $Headers -OutFile $OutFile | Out-Null
            return $OutFile
        }
        elseif ($Body) {
            $JsonBody = $Body | ConvertTo-Json -Depth 10
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $JsonBody -ContentType 'application/json'
        } else {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
        }
    }
    catch {
        $message = "Robopack API error ($Method $Uri): $($_.Exception.Message)"
        $details = @()

        if ($_.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($_.ErrorDetails.Message)) {
            $details += "Error details: $($_.ErrorDetails.Message)"
        }

        $resp = $_.Exception.Response
        if ($resp) {
            try {
                if ($null -ne $resp.StatusCode) {
                    $details += "HTTP status: $([int]$resp.StatusCode) $($resp.StatusDescription)"
                }
            }
            catch {
            }

            try {
                $stream = $resp.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $body = $reader.ReadToEnd()
                    if (-not [string]::IsNullOrWhiteSpace($body)) {
                        $details += "Response body: $body"
                    }
                }
            }
            catch {
            }
        }

        if ($details.Count -gt 0) {
            throw ($message + "`n" + ($details -join "`n"))
        }

        throw $message
    }
}