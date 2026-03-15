function Get-RobopackPackage {
    <#
    .SYNOPSIS
    Gets packages from Robopack.

    .DESCRIPTION
    Retrieves packages from the Robopack API endpoint /v1/package.
    Supports search, filtering by AppId, sorting, and paging.
    By default, the function iterates pages until no more results are returned.
    Use DisablePaging to request all results in one call.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER Search
    Text to search packages for.
    Alias: Name.

    .PARAMETER AppId
    Specify an Instant app ID to only return packages for that app.

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

    .PARAMETER FirstMatch
    Stops scanning and returns the first package object found.

    .PARAMETER DisablePaging
    If specified, paging is disabled and all matching results are requested in one call.

    .EXAMPLE
    Get-RobopackPackage -ApiKey $apiKey
    Returns all packages by paging through all result pages.

    .EXAMPLE
    Get-RobopackPackage -ApiKey $apiKey -Search "Notepad++" -SortBy ProductVersion -SortDesc $true
    Returns packages matching Notepad++ sorted by ProductVersion descending.

    .EXAMPLE
    Get-RobopackPackage -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555" -ItemsPerPage 100
    Returns packages for one app, requesting 100 results per page.

    .EXAMPLE
    Get-RobopackPackage -ApiKey $apiKey -DisablePaging -FirstMatch
    Requests all results in one call and returns the first match found.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Alias('Name')]
        [string]$Search,

        [guid]$AppId,

        [string]$SortBy,

        [Nullable[bool]]$SortDesc,

        [int]$Page = 1,

        [ValidateRange(1, 1000)]
        [int]$ItemsPerPage = 50,

        [switch]$FirstMatch,

        [switch]$DisablePaging
    )

    function New-RobopackPackageObject {
        param([object]$Package)

        [PSCustomObject]@{
            Id                  = $Package.id
            AppId               = $Package.appId
            Created             = $Package.created
            ProductName         = $Package.productName
            Manufacturer        = $Package.manufacturer
            ProductVersion      = $Package.productVersion
            State               = $Package.state
            FullProductName     = $Package.fullProductName
            FileName            = $Package.fileName
            Size                = $Package.size
            DownloadAvailable   = $Package.downloadAvailable
            NewVersionAvailable = $Package.newVersionAvailable
            ImportInfo          = $Package.importInfo
            LatestVersion       = $Package.latestVersion
            Source              = $Package.source
            IsCustom            = $Package.isCustom
            UserScope           = $Package.userScope
            MachineScope        = $Package.machineScope
        }
    }

    $BaseQuery = @{}

    if ($Search) {
        $BaseQuery.Search = $Search
    }

    if ($PSBoundParameters.ContainsKey('AppId')) {
        $BaseQuery.AppId = $AppId.Guid
    }

    if ($SortBy) {
        $BaseQuery.SortBy = $SortBy
    }

    if ($PSBoundParameters.ContainsKey('SortDesc')) {
        $BaseQuery.SortDesc = $SortDesc
    }

    $TotalProcessed = 0

    if ($DisablePaging) {
        # Get all results in a single request.
        $Query = @{} + $BaseQuery
        $Query.DisablePaging = $true

        $Result = Invoke-RobopackApi `
            -Method GET `
            -Endpoint "package" `
            -Query $Query `
            -ApiKey $ApiKey

        foreach ($app in $Result) {
            $TotalProcessed++
            Write-Progress -Activity "Scanning packages" -Status "Processed $TotalProcessed package(s)"

            $obj = New-RobopackPackageObject -Package $app

            if ($FirstMatch) {
                Write-Progress -Activity "Scanning packages" -Completed
                Write-Verbose "Match found after scanning $TotalProcessed package(s)."
                return $obj
            }

            $obj
        }
    }
    else {
        # Retrieve all pages until no more results are returned.
        $CurrentPage = $Page

        while ($true) {
            $Query = @{} + $BaseQuery
            $Query.Page = $CurrentPage
            $Query.ItemsPerPage = $ItemsPerPage

            $Result = Invoke-RobopackApi `
                -Method GET `
                -Endpoint "package" `
                -Query $Query `
                -ApiKey $ApiKey

            if ($Result.Count -eq 0) {
                break
            }

            foreach ($app in $Result) {
                $TotalProcessed++
                Write-Progress -Activity "Scanning packages" -Status "Processed $TotalProcessed package(s)"

                $obj = New-RobopackPackageObject -Package $app

                if ($FirstMatch) {
                    Write-Progress -Activity "Scanning packages" -Completed
                    Write-Verbose "Match found after scanning $TotalProcessed package(s)."
                    return $obj
                }

                $obj
            }

            $CurrentPage++
        }
    }

    Write-Progress -Activity "Scanning packages" -Completed
    Write-Verbose "Finished scanning. Total packages processed: $TotalProcessed"
}
