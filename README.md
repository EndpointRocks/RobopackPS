# RobopackPS

Robopack is a platform for packaging, deploying, and keeping third-party applications up to date in Microsoft Intune. Learn more at https://robopack.com.

RobopackPS is a PowerShell module for automating software packaging, deployment flows, and operational tasks in Robopack and Microsoft Intune.
It works well for both standard catalog apps and custom apps, and it makes it easy to retrieve operational and package data from Robopack.

## Project Links

- GitHub: https://github.com/EndpointRocks/RobopackPS
- Issues and support: https://github.com/EndpointRocks/RobopackPS/issues

## Status

- Public source repository is available now.
- Module is live on PowerShell Gallery: https://www.powershellgallery.com/packages/RobopackPS

## What You Can Do

- Discover packages, instant apps, tenants, templates, and radar data
- Work effectively with both standard apps and custom apps
- Download package files, package PDF documentation, and template assets
- Create local package scaffolds, validate them, and publish to Robopack
- Create flows and manage deployments (start, stop, refresh, skip wave, content update)
- Manually upload package content to a tenant and track upload task status
- Retrieve detailed operational information from Robopack for troubleshooting and automation

## Requirements

- PowerShell 5.1 or later
- A valid Robopack API key

## Installation

Install from PowerShell Gallery:

```powershell
Install-Module -Name RobopackPS -Repository PSGallery -Scope CurrentUser
```

If you have not trusted PSGallery yet:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name RobopackPS -Repository PSGallery -Scope CurrentUser
```

Import module after install:

```powershell
Import-Module RobopackPS -Force
```

Update to latest version:

```powershell
Update-Module -Name RobopackPS
```

Alternative for development from source (module root `RobopackPS`):

```powershell
Import-Module .\RobopackPS.psd1 -Force
```

This repository is the public source for the module.

## Authentication

All cmdlets require `-ApiKey`.
Always store your API key in a secure location, such as the
Microsoft.PowerShell.SecretManagement module or Azure Key Vault.
The example below uses `Get-Secret` from the Microsoft.PowerShell.SecretManagement module.

```powershell
$key = Get-Secret -Name "Robopack-ApiKey" -AsPlainText
```

Tip: add `-Verbose` when you want detailed progress and operation messages.

## 5-Minute Quick Start

```powershell
# 1) List packages
Get-RobopackPackage -ApiKey $key

# 2) Create a flow from a package
$flow = New-RobopackFlow -ApiKey $key -PackageId "11111111-2222-3333-4444-555555555555" -Name "My First Flow"

# 3) Add a deployment
$deployment = Add-RobopackFlowDeployment -ApiKey $key -FlowId $flow.id -PackageId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

# 4) Start deployment processing
Start-RobopackFlowDeployment -ApiKey $key -DeploymentId $deployment.id

# 5) Wait for start status
Wait-RobopackFlowDeploymentStart -ApiKey $key -DeploymentId $deployment.id -PollIntervalSeconds 15 -TimeoutMinutes 30
```

## Core Workflows

### Packages

```powershell
# Search/list packages
Get-RobopackPackage -ApiKey $key -Search "Notepad++"

# Single package details
Get-RobopackPackageDetails -ApiKey $key -PackageId "11111111-2222-3333-4444-555555555555"

# Downloads
Save-RobopackPackageFile -ApiKey $key -PackageId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
Save-RobopackPackageDocumentationPdf -ApiKey $key -PackageId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
```

### Build and Publish

```powershell
# Create local scaffold
Initialize-RobopackPackage -Path ".\MyPackage" -Msi

# Validate before upload
Test-RobopackPackage -Path ".\MyPackage"

# Publish to Robopack
Publish-RobopackPackage -ApiKey $key -Path ".\MyPackage"
```

### Flows and Deployments

```powershell
# Create flow and deployment
$flow = New-RobopackFlow -ApiKey $key -PackageId "11111111-2222-3333-4444-555555555555" -Name "My Flow"
$deployment = Add-RobopackFlowDeployment -ApiKey $key -FlowId $flow.id -PackageId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

# Deployment lifecycle
Start-RobopackFlowDeployment -ApiKey $key -DeploymentId $deployment.id
Update-RobopackFlowDeploymentStatus -ApiKey $key -DeploymentId $deployment.id
Skip-RobopackFlowDeploymentWave -ApiKey $key -DeploymentId $deployment.id
Stop-RobopackFlowDeployment -ApiKey $key -DeploymentId $deployment.id

# Content update operation
Update-RobopackFlowDeploymentContent -ApiKey $key -DeploymentId $deployment.id
Wait-RobopackFlowDeploymentContentUpdate -ApiKey $key -DeploymentId $deployment.id -PollIntervalSeconds 15 -TimeoutMinutes 60
```

### Tenants and Manual Upload

```powershell
# Tenant discovery
Get-RobopackTenants -ApiKey $key
Get-RobopackTenantDetails -ApiKey $key -TenantId "11111111-2222-3333-4444-555555555555"

# Manual upload task
$task = Publish-RobopackTenantPackage -ApiKey $key -TenantId "11111111-2222-3333-4444-555555555555" -PackageId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -Wait

# Poll upload status later if needed
Get-RobopackTenantUploadStatus -ApiKey $key -UploadId $task.id
```

### Instant Apps and Templates

```powershell
# Instant apps
Get-RobopackInstantApps -ApiKey $key
Get-RobopackInstantAppsDetails -ApiKey $key -AppId "11111111-2222-3333-4444-555555555555"
Import-RobopackInstantApp -ApiKey $key -AppId "11111111-2222-3333-4444-555555555555"

# Script templates
Get-RobopackScriptTemplate -ApiKey $key
Get-RobopackScriptTemplateDetails -ApiKey $key -TemplateId "11111111-2222-3333-4444-555555555555"
Save-RobopackScriptTemplateBanner -ApiKey $key -TemplateId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
Save-RobopackScriptTemplateLogo -ApiKey $key -TemplateId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
```

### Radar

```powershell
Get-RobopackRadarApps -ApiKey $key -TenantId "11111111-2222-3333-4444-555555555555"
Get-RobopackRadarAppDevices -ApiKey $key -TenantId "11111111-2222-3333-4444-555555555555" -AppId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
Get-RobopackRadarEntryDevices -ApiKey $key -TenantId "11111111-2222-3333-4444-555555555555" -EntryId "ffffffff-1111-2222-3333-444444444444"
```

## Important Notes

- `Publish-RobopackTenantPackage` is a manual upload and is not automatically kept up to date by Robopack.
- Use flow endpoints for automated patch flows that stay up to date over time.
- Use `-WhatIf` for destructive cmdlets where supported.

## Support

- Use GitHub issues for bug reports, documentation fixes, and feature requests.
- Include the cmdlet name, relevant parameters, and any Robopack API error message when reporting an issue.
- Include your PowerShell version (`$PSVersionTable.PSVersion`) and whether you run Windows PowerShell 5.1 or PowerShell 7+.
