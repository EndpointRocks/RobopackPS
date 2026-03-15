function Get-RobopackRadarApps {
    <#
    .SYNOPSIS
    Gets Radar apps for a tenant.

    .DESCRIPTION
    Retrieves Radar apps from the Robopack API endpoint:
    /v1/tenant/{tenantId}/radar
    Supports search, filtering, sorting, and paging.
    By default, the function iterates pages until no more results are returned.
    Use DisablePaging to request all matching results in one call.

    .PARAMETER TenantId
    The tenant ID. If omitted, the default tenant ID is used.

    .PARAMETER Search
    Text to search Radar apps for.

    .PARAMETER Matched
    If set, filters results to matched/unmatched Radar apps.

    .PARAMETER IncludeManaged
    If set, includes or excludes managed apps.

    .PARAMETER IncludeModernApps
    If set, includes or excludes modern apps.

    .PARAMETER SortBy
    Name of the property to sort query results by.

    .PARAMETER SortDesc
    If set to $true, sort order is descending.
    If set to $false, sort order is ascending.

    .PARAMETER Page
    Index of the first page to request when paging is enabled.
    Default is 1.

    .PARAMETER ItemsPerPage
    Number of results returned per page.
    Default: 50. Maximum: 1000.

    .PARAMETER DisablePaging
    If set to $true, paging is disabled and all matching results are requested in one call.
    If set to $false, paging is enabled.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackRadarApps -ApiKey $apiKey
    Returns all Radar apps in the default tenant.

    .EXAMPLE
    Get-RobopackRadarApps -ApiKey $apiKey -Search "Notepad" -Matched $true -SortBy Name -SortDesc $true
    Returns matched Radar apps containing Notepad, sorted descending by Name.

    .EXAMPLE
    Get-RobopackRadarApps -TenantId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -ApiKey $apiKey -ItemsPerPage 100 -Page 2
    Starts reading from page 2 in a specific tenant, with 100 items per page.

    .EXAMPLE
    Get-RobopackRadarApps -ApiKey $apiKey -DisablePaging $true
    Requests all matching Radar apps in one call.

    .EXAMPLE
    Get-RobopackRadarApps -ApiKey $apiKey -DisablePaging $true -Verbose
    Shows which retrieval mode was used (disablePaging direct or fallback paging).
    #>
    [CmdletBinding()]
    param(
        [Guid] $TenantId,
        [string] $Search,
        [Nullable[bool]] $Matched,
        [Nullable[bool]] $IncludeManaged,
        [Nullable[bool]] $IncludeModernApps,
        [string] $SortBy,
        [Nullable[bool]] $SortDesc,
        [int] $Page,
        [ValidateRange(1,1000)][int] $ItemsPerPage = 50,
        [Nullable[bool]] $DisablePaging,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    if (-not $TenantId) { $TenantId = Get-RobopackDefaultTenantId }

    $endpoint = "tenant/$TenantId/radar"
    $baseQuery = @{}

    if ($PSBoundParameters.ContainsKey('Search')) {
        $baseQuery.search = $Search
    }

    if ($PSBoundParameters.ContainsKey('Matched')) {
        $baseQuery.matched = $Matched
    }

    if ($PSBoundParameters.ContainsKey('IncludeManaged')) {
        $baseQuery.includeManaged = $IncludeManaged
    }

    if ($PSBoundParameters.ContainsKey('IncludeModernApps')) {
        $baseQuery.includeModernApps = $IncludeModernApps
    }

    if ($PSBoundParameters.ContainsKey('SortBy')) {
        $baseQuery.sortBy = $SortBy
    }

    if ($PSBoundParameters.ContainsKey('SortDesc')) {
        $baseQuery.sortDesc = $SortDesc
    }

    if ($PSBoundParameters.ContainsKey('DisablePaging')) {
        $baseQuery.disablePaging = $DisablePaging
    }

    function Resolve-RobopackRadarItems {
        param(
            [Parameter()]
            [object]$Response
        )

        if ($null -eq $Response) {
            return @()
        }

        if ($Response -is [System.Array]) {
            return @($Response)
        }

        if ($Response.PSObject.Properties.Match('items').Count -gt 0) {
            return @($Response.items)
        }

        return @($Response)
    }

    function Get-RobopackRadarAppsPaged {
        param(
            [Parameter(Mandatory)]
            [hashtable]$QueryBase,

            [Parameter(Mandatory)]
            [int]$StartPage,

            [Parameter(Mandatory)]
            [int]$PageSize
        )

        $pageIndex = $StartPage
        $all = @()

        Write-Verbose "Retrieval mode: paged"
        Write-Verbose "Starting at page $StartPage with page size $PageSize."

        do {
            $query = @{} + $QueryBase
            $query.page = $pageIndex
            $query.itemsPerPage = $PageSize

            $pageResponse = Invoke-RobopackApi `
                -Method GET `
                -Endpoint $endpoint `
                -Query $query `
                -ApiKey $ApiKey

            $pageItems = Resolve-RobopackRadarItems -Response $pageResponse
            if ($pageItems.Count -gt 0) {
                $all += $pageItems
            }

            $cnt = $pageItems.Count
            $pageIndex++

        } while ($cnt -gt 0 -and $cnt -eq $PageSize)

        return $all
    }

    if ($DisablePaging -ne $true) {
        $startPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        return Get-RobopackRadarAppsPaged -QueryBase $baseQuery -StartPage $startPage -PageSize $ItemsPerPage
    }
    else {
        $query = @{} + $baseQuery

        Write-Verbose "Retrieval mode: disablePaging=true (single request)."

        $response = Invoke-RobopackApi `
            -Method GET `
            -Endpoint $endpoint `
            -Query $query `
            -ApiKey $ApiKey

        $items = Resolve-RobopackRadarItems -Response $response
        if ($items.Count -gt 0) {
            Write-Verbose "disablePaging request returned $($items.Count) item(s)."
            return $items
        }

        # Fallback for API responses that do not return data with disablePaging=true.
        Write-Verbose "disablePaging request returned no items. Falling back to paged retrieval."
        $fallbackBaseQuery = @{} + $baseQuery
        if ($fallbackBaseQuery.ContainsKey('disablePaging')) {
            $fallbackBaseQuery.Remove('disablePaging') | Out-Null
        }
        $startPage = if ($PSBoundParameters.ContainsKey('Page')) { $Page } else { 1 }
        return Get-RobopackRadarAppsPaged -QueryBase $fallbackBaseQuery -StartPage $startPage -PageSize $ItemsPerPage
    }
}
