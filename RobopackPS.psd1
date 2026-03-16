@{
    RootModule        = 'RobopackPS.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'cf21d18c-69a8-4b91-a7df-78f6fab88466'
    Author            = 'Tobias Sandberg'
    CompanyName       = 'Endpoint.Rocks'
    Description       = 'RobopackPS is a PowerShell module for interacting with the Robopack Web API, enabling automation of packaging instant apps, custom apps, Robopatch flows, Radar insights, and other operational tasks in Robopack—and thereby Microsoft Intune.'
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion = '5.1'
    Copyright         = '(c) 2026 Endpoint.Rocks. All rights reserved.'
    FunctionsToExport = @(
        'Add-RobopackFlowDeployment',
        'Get-RobopackFlow',
        'Get-RobopackFlowDeploymentDetails',
        'Get-RobopackFlowDetails',
        'Get-RobopackFlowWaveDetails',
        'Get-RobopackFlowWaveLive',
        'Get-RobopackInstantApps',
        'Get-RobopackInstantAppsDetails',
        'Get-RobopackInstantAppsShowcased',
        'Get-RobopackInstantAppsVerified',
        'Get-RobopackPackage',
        'Get-RobopackPackageDetails',
        'Get-RobopackRadarAppDevices',
        'Get-RobopackRadarApps',
        'Get-RobopackRadarEntryDevices',
        'Get-RobopackScriptTemplate',
        'Get-RobopackScriptTemplateDetails',
        'Get-RobopackTenantDetails',
        'Get-RobopackTenants',
        'Get-RobopackTenantUploadStatus',
        'Import-RobopackInstantApp',
        'Initialize-RobopackPackage',
        'New-RobopackFlow',
        'Publish-RobopackPackage',
        'Update-RobopackFlowDeploymentStatus',
        'Remove-RobopackFlow',
        'Remove-RobopackFlowDeployment',
        'Save-RobopackPackageDocumentationPdf',
        'Save-RobopackPackageFile',
        'Save-RobopackScriptTemplateBanner',
        'Save-RobopackScriptTemplateLogo',
        'Skip-RobopackFlowDeploymentWave',
        'Start-RobopackFlowDeployment',
        'Stop-RobopackFlowDeployment',
        'Test-RobopackPackage',
        'Update-RobopackFlowDeploymentContent',
        'Publish-RobopackTenantPackage',
        'Wait-RobopackFlowDeploymentContentUpdate',
        'Wait-RobopackFlowDeploymentStart'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('Robopack', 'Intune', 'Packaging', 'Automation', 'PowerShell')
            ProjectUri = 'https://github.com/EndpointRocks/RobopackPS'
            LicenseUri = 'https://github.com/EndpointRocks/RobopackPS/blob/main/LICENSE'
            ReleaseNotes = 'Initial public release of RobopackPS with package, flow, tenant, template, and radar automation cmdlets.'
        }
    }
}
