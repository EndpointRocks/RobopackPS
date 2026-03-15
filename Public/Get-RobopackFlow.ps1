function Get-RobopackFlow {
    <#
    .SYNOPSIS
    Gets flows from Robopack.

    .DESCRIPTION
    Retrieves flows from the Robopack API endpoint /v1/flow.
    Supports search, filtering, sorting, and paging.
    By default, the function iterates pages until no more results are returned.
    Use DisablePaging to request all matching results in one call.

    .PARAMETER Search
    Text to search flows for.

    .PARAMETER ShowDeleted
    If set, filters by deleted/non-deleted flows.

    .PARAMETER AppId
    If set, only flows for the specified app ID are returned.

    .PARAMETER Tenants
    Optional list of tenant IDs to filter returned flows by.

    .PARAMETER SortBy
    Name of the property to sort query results by.

    .PARAMETER SortDesc
    If set to $true, sort order is descending.
    If set to $false, sort order is ascending.

    .PARAMETER Page
    Index of page of results to return.

    .PARAMETER ItemsPerPage
    Number of results returned per page.
    Default: 50. Maximum: 1000.

    .PARAMETER DisablePaging
    If set to $true, paging is disabled and all matching results are requested.
    If set to $false, paging is enabled.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackFlow -ApiKey $apiKey
    Returns all flows by paging through all result pages.

    .EXAMPLE
    Get-RobopackFlow -ApiKey $apiKey -Search "Acrobat" -SortBy Name -SortDesc
    Returns flows matching Acrobat sorted by Name in descending order.

    .EXAMPLE
    Get-RobopackFlow -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555" -ItemsPerPage 100 -Page 2
    Starts reading flows for one app from page 2 with 100 items per page.

    .EXAMPLE
    Get-RobopackFlow -ApiKey $apiKey -Tenants @("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", "11111111-2222-3333-4444-555555555555")
    Returns flows filtered to the specified tenant IDs.
    #>
    [CmdletBinding()]
    param(
        [string] $Search,
        [Nullable[bool]] $ShowDeleted,
        [Nullable[guid]] $AppId,
        [string[]] $Tenants,
        [string] $SortBy,
        [Nullable[bool]] $SortDesc,
        [int] $Page = 1,
        [ValidateRange(1,1000)][int] $ItemsPerPage = 50,
        [Nullable[bool]] $DisablePaging,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $endpoint = "flow"
    $baseQuery = @{}

    if ($PSBoundParameters.ContainsKey('Search')) {
        $baseQuery.search = $Search
    }

    if ($PSBoundParameters.ContainsKey('ShowDeleted')) {
        $baseQuery.showDeleted = $ShowDeleted
    }

    if ($PSBoundParameters.ContainsKey('AppId')) {
        $baseQuery.appId = $AppId.Guid
    }

    if ($PSBoundParameters.ContainsKey('Tenants')) {
        $baseQuery['tenants[]'] = $Tenants
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

    if ($DisablePaging -ne $true) {
        $pageIndex = $Page
        $pageSize  = $ItemsPerPage
        $all = @()

        do {
            $query = @{} + $baseQuery
            $query.page = $pageIndex
            $query.itemsPerPage = $pageSize

            $pageResult = Invoke-RobopackApi `
                -Method GET `
                -Endpoint $endpoint `
                -Query $query `
                -ApiKey $ApiKey

            if ($pageResult) { 
                $all += @($pageResult)
            }

            $cnt = @($pageResult).Count
            $pageIndex++

        } while ($cnt -gt 0 -and $cnt -eq $pageSize)

        return $all
    }
    else {
        $query = @{} + $baseQuery
        $query.disablePaging = $true

        return Invoke-RobopackApi `
            -Method GET `
            -Endpoint $endpoint `
            -Query $query `
            -ApiKey $ApiKey
    }
}
