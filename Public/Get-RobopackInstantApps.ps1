function Get-RobopackInstantApps {
    <#
    .SYNOPSIS
    Searches Instant apps.

    .DESCRIPTION
    Searches the Robopack Instant app library using the API endpoint /v1/app.
    Supports free-text search, filtering properties, sorting, and paging.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER Search
    Text to search through Instant apps for.

    .PARAMETER Showcased
    If set to $true, only showcased apps are returned.
    If set to $false, showcased-only filtering is disabled.
    Alias: ShowcasedOnly.

    .PARAMETER Verified
    If set to $true, only verified apps are returned.
    If set to $false, verified-only filtering is disabled.
    Alias: VerifiedOnly.

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
    Number of results returned per page.
    Default: 50. Maximum: 1000.

    .EXAMPLE
    Get-RobopackInstantApps -ApiKey $apiKey -Search "Acrobat"
    Searches Instant apps for Acrobat.

    .EXAMPLE
    Get-RobopackInstantApps -ApiKey $apiKey -Verified $true -Showcased $true -SortBy Name -SortDesc $true -Page 1 -ItemsPerPage 100
    Returns verified and showcased Instant apps sorted by name descending.

    .EXAMPLE
    Get-RobopackInstantApps -ApiKey $apiKey -DisablePaging $true
    Returns all Instant apps with paging disabled.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [string]$Search,

        [Alias('VerifiedOnly')]
        [Nullable[bool]]$Verified,

        [Alias('ShowcasedOnly')]
        [Nullable[bool]]$Showcased,

        [Nullable[bool]]$Logo,

        [string]$SortBy,

        [Nullable[bool]]$SortDesc,

        [int]$Page,

        [Nullable[bool]]$DisablePaging,

        [ValidateRange(1,1000)]
        [int]$ItemsPerPage = 50
    )

    $Query = @{}

    if ($PSBoundParameters.ContainsKey('Search')) {
        $Query.search = $Search
    }

    if ($PSBoundParameters.ContainsKey('Verified')) {
        $Query.verified = $Verified
    }

    if ($PSBoundParameters.ContainsKey('Showcased')) {
        $Query.showcased = $Showcased
    }

    if ($PSBoundParameters.ContainsKey('Logo')) {
        $Query.logo = $Logo
    }

    if ($PSBoundParameters.ContainsKey('SortBy')) {
        $Query.sortBy = $SortBy
    }

    if ($PSBoundParameters.ContainsKey('SortDesc')) {
        $Query.sortDesc = $SortDesc
    }

    if ($PSBoundParameters.ContainsKey('Page')) {
        $Query.page = $Page
    }

    if ($PSBoundParameters.ContainsKey('DisablePaging')) {
        $Query.disablePaging = $DisablePaging
    }

    $Query.itemsPerPage = $ItemsPerPage

    $Result = Invoke-RobopackApi `
        -Method GET `
        -Endpoint "app" `
        -Query $Query `
        -ApiKey $ApiKey

    return $Result
}
