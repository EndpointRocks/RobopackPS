function Get-RobopackDefaultTenantId {
    <#
    .SYNOPSIS
    Returns the default Robopack tenant id configured in the module.

    .DESCRIPTION
    Reads the module-scoped default tenant id from `$script:RoboDefaultTenantId
    and returns it when available. Throws an error if no default tenant id has
    been configured.
    #>
    [CmdletBinding()]
    param()

    if ($script:RoboDefaultTenantId) {
        return $script:RoboDefaultTenantId
    }

    throw "TenantId is missing. Provide -TenantId or set `$script:RoboDefaultTenantId in the module."
}
