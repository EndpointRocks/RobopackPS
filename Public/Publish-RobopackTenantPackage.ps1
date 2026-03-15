function Publish-RobopackTenantPackage {
    <#
    .SYNOPSIS
    Uploads a package to an Intune tenant.

    .DESCRIPTION
    Calls Robopack API endpoint POST /v1/tenant/{id}/upload.
    Uploads a specific package to an Intune tenant as a manual upload.
    Manual uploads are not automatically kept up-to-date by Robopack.
    Returns an object representing the upload task.

    .PARAMETER TenantId
    ID of the Intune tenant.

    .PARAMETER PackageId
    ID of the package to upload.

    .PARAMETER UploadMsixAsWin32
    For MSIX packages, indicates whether the package should be wrapped and
    uploaded as a Win32 app instead of a Line-of-Business app.
    Default: $true.

    .PARAMETER Wait
    If specified, the request waits until the package is fully uploaded to
    Intune before returning.
    Default behavior when omitted is non-blocking.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Publish-RobopackTenantPackage -ApiKey $apiKey -TenantId "11111111-2222-3333-4444-555555555555" -PackageId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    Starts a manual package upload task for the specified tenant.

    .EXAMPLE
    Publish-RobopackTenantPackage -ApiKey $apiKey -TenantId "11111111-2222-3333-4444-555555555555" -PackageId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -UploadMsixAsWin32 $false -Wait
    Uploads package content and waits for completion, using LoB mode for MSIX.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid] $TenantId,

        [Parameter(Mandatory)]
        [guid] $PackageId,

        [bool] $UploadMsixAsWin32 = $true,

        [switch] $Wait,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $query = @{
        packageId = $PackageId
    }

    if ($PSBoundParameters.ContainsKey('UploadMsixAsWin32')) {
        $query.uploadMsixAsWin32 = $UploadMsixAsWin32
    }

    if ($Wait) {
        $query.wait = $true
    }

    return Invoke-RobopackApi `
        -Method POST `
        -Endpoint "tenant/$TenantId/upload" `
        -Query $query `
        -ApiKey $ApiKey
}