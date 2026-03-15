function Get-RobopackInstantAppsShowcased {
    <#
    .SYNOPSIS
    Gets list of showcased Instant apps.

    .DESCRIPTION
    Retrieves Instant apps from the Robopack API endpoint /v1/app/showcase.
    Supports searching, filtering properties, sorting, and paging.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER Search
    Text to search through Instant apps for.

    .PARAMETER Showcased
    If set to $true, indicates that only showcased apps should be returned.
    If set to $false, showcased-only filtering is disabled.

    .PARAMETER Verified
    If set to $true, indicates that only verified apps should be returned.
    If set to $false, verified-only filtering is disabled.

    .PARAMETER Logo
    Indicates if the Logo property in the results should be populated with binary logo image data.

    .PARAMETER SortBy
    Name of property to sort query by.

    .PARAMETER SortDesc
    If set to $true, sort order is descending.
    If set to $false, sort order is ascending.

    .PARAMETER Page
    Index of page of results to return.

    .PARAMETER DisablePaging
    If set to $true, paging is disabled and all results are returned.
    If set to $false, paging is enabled.

    .PARAMETER ItemsPerPage
    The number of results returned per page. Default: 50, max: 1000.

    .EXAMPLE
    Get-RobopackInstantAppsShowcased -ApiKey $apiKey

    .EXAMPLE
    Get-RobopackInstantAppsShowcased -ApiKey $apiKey -Search "Notepad" -Verified $true -SortBy Name -SortDesc $true
    Returns verified showcased apps matching Notepad sorted by Name descending.

    .EXAMPLE
    Get-RobopackInstantAppsShowcased -ApiKey $apiKey -DisablePaging $true
    Returns all showcased app results with paging disabled.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [string]$Search,

        [Nullable[bool]]$Showcased,

        [Nullable[bool]]$Verified,

        [Nullable[bool]]$Logo,

        [string]$SortBy,

        [Nullable[bool]]$SortDesc,

        [int]$Page,

        [Nullable[bool]]$DisablePaging,

        [ValidateRange(1, 1000)]
        [int]$ItemsPerPage = 50
    )

    $query = @{}

    if ($PSBoundParameters.ContainsKey('Search')) {
        $query.search = $Search
    }

    if ($PSBoundParameters.ContainsKey('Showcased')) {
        $query.showcased = $Showcased
    }

    if ($PSBoundParameters.ContainsKey('Verified')) {
        $query.verified = $Verified
    }

    if ($PSBoundParameters.ContainsKey('Logo')) {
        $query.logo = $Logo
    }

    if ($PSBoundParameters.ContainsKey('SortBy')) {
        $query.sortBy = $SortBy
    }

    if ($PSBoundParameters.ContainsKey('SortDesc')) {
        $query.sortDesc = $SortDesc
    }

    if ($PSBoundParameters.ContainsKey('Page')) {
        $query.page = $Page
    }

    if ($PSBoundParameters.ContainsKey('DisablePaging')) {
        $query.disablePaging = $DisablePaging
    }

    if ($PSBoundParameters.ContainsKey('ItemsPerPage')) {
        $query.itemsPerPage = $ItemsPerPage
    }

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint "app/showcase" `
        -Query $query `
        -ApiKey $ApiKey
}
