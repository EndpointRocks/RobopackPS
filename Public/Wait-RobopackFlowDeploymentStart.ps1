function Wait-RobopackFlowDeploymentStart {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Guid] $DeploymentId,

        [ValidateRange(1, 3600)]
        [int] $PollIntervalSeconds = 15,

        [ValidateRange(1, 1440)]
        [int] $TimeoutMinutes = 30,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    $startedAt = Get-Date
    $deadline = $startedAt.AddMinutes($TimeoutMinutes)
    $lastStatus = $null

    while ((Get-Date) -lt $deadline) {
        $details = Get-RobopackFlowDeploymentDetails -DeploymentId $DeploymentId -ApiKey $ApiKey

        $statusCandidates = @(
            $details.startStatus,
            $details.deploymentStatus,
            $details.taskStatus,
            $details.operationStatus,
            $details.status,
            $details.state,
            $(if ($details.start) { $details.start.status } else { $null }),
            $(if ($details.start) { $details.start.state } else { $null })
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }

        $status = if ($statusCandidates.Count -gt 0) { [string]$statusCandidates[0] } else { $null }
        $statusNormalized = if ($status) { $status.Trim().ToLowerInvariant() } else { $null }
        $lastStatus = $status

        $isStartedCandidates = @(
            $details.isStarted,
            $details.started,
            $details.isRunning,
            $(if ($details.start) { $details.start.started } else { $null }),
            $(if ($details.start) { $details.start.isStarted } else { $null })
        ) | Where-Object { $null -ne $_ }

        $isStarted = $null
        if ($isStartedCandidates.Count -gt 0) {
            $isStarted = [bool]$isStartedCandidates[0]
        }

        $isSuccess = $statusNormalized -in @('started','running','inprogress','in-progress','active','deploying','completed','complete','succeeded','success')
        $isFailure = $statusNormalized -in @('failed','error','cancelled','canceled')

        if ($isSuccess -or ($null -ne $isStarted -and $isStarted)) {
            return [PSCustomObject]@{
                Started        = $true
                Succeeded      = $true
                Status         = $(if ($status) { $status } else { 'Started' })
                DeploymentId   = $DeploymentId
                StartedAt      = $startedAt
                FinishedAt     = Get-Date
                ElapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
                Details        = $details
            }
        }

        if ($isFailure) {
            return [PSCustomObject]@{
                Started        = $false
                Succeeded      = $false
                Status         = $status
                DeploymentId   = $DeploymentId
                StartedAt      = $startedAt
                FinishedAt     = Get-Date
                ElapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
                Details        = $details
            }
        }

        $elapsedSeconds = [int]((Get-Date) - $startedAt).TotalSeconds
        Write-Verbose "Waiting for deployment start... Status: $status | Elapsed: ${elapsedSeconds}s"
        Start-Sleep -Seconds $PollIntervalSeconds
    }

    throw "Timed out after $TimeoutMinutes minute(s) while waiting for deployment start. Last status: $lastStatus"
}
