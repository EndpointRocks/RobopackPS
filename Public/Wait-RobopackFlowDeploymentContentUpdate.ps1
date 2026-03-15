function Wait-RobopackFlowDeploymentContentUpdate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $DeploymentId,

        [ValidateRange(1, 3600)]
        [int] $PollIntervalSeconds = 15,

        [ValidateRange(1, 1440)]
        [int] $TimeoutMinutes = 60,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $startedAt = Get-Date
    $deadline = $startedAt.AddMinutes($TimeoutMinutes)
    $lastStatus = $null

    while ((Get-Date) -lt $deadline) {
        $details = Get-RobopackFlowDeploymentDetails -DeploymentId $DeploymentId -ApiKey $ApiKey

        $statusCandidates = @(
            $details.contentUpdateStatus,
            $details.updateContentStatus,
            $details.taskStatus,
            $details.operationStatus,
            $details.status,
            $details.state,
            $(if ($details.contentUpdate) { $details.contentUpdate.status } else { $null }),
            $(if ($details.contentUpdate) { $details.contentUpdate.state } else { $null })
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }

        $status = if ($statusCandidates.Count -gt 0) { [string]$statusCandidates[0] } else { $null }
        $statusNormalized = if ($status) { $status.Trim().ToLowerInvariant() } else { $null }
        $lastStatus = $status

        $isUpdatingCandidates = @(
            $details.isUpdatingContent,
            $details.updatingContent,
            $(if ($details.contentUpdate) { $details.contentUpdate.isUpdating } else { $null }),
            $(if ($details.contentUpdate) { $details.contentUpdate.inProgress } else { $null })
        ) | Where-Object { $null -ne $_ }

        $isUpdating = $null
        if ($isUpdatingCandidates.Count -gt 0) {
            $isUpdating = [bool]$isUpdatingCandidates[0]
        }

        $isSuccess = $statusNormalized -in @('completed','complete','succeeded','success')
        $isFailure = $statusNormalized -in @('failed','error','cancelled','canceled')

        if ($isSuccess -or $isFailure) {
            return [PSCustomObject]@{
                Completed      = $true
                Succeeded      = $isSuccess
                Status         = $status
                DeploymentId   = $DeploymentId
                StartedAt      = $startedAt
                FinishedAt     = Get-Date
                ElapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
                Details        = $details
            }
        }

        if ($null -ne $isUpdating -and -not $isUpdating) {
            return [PSCustomObject]@{
                Completed      = $true
                Succeeded      = $true
                Status         = $(if ($status) { $status } else { 'Completed' })
                DeploymentId   = $DeploymentId
                StartedAt      = $startedAt
                FinishedAt     = Get-Date
                ElapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
                Details        = $details
            }
        }

        $elapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
        Write-Verbose "Waiting for deployment content update... Status: $status | Elapsed: ${elapsedSeconds}s"
        Start-Sleep -Seconds $PollIntervalSeconds
    }

    throw "Timed out after $TimeoutMinutes minute(s) while waiting for deployment content update. Last status: $lastStatus"
}
