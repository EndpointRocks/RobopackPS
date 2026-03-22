BeforeAll {
    $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    $manifestFile = Get-ChildItem -Path $repoRoot -Recurse -File -Filter '*.psd1' |
        Where-Object { $_.FullName -notmatch '[\\/]\.github[\\/]' } |
        Select-Object -First 1

    if (-not $manifestFile) {
        throw 'No module manifest (.psd1) found for tests.'
    }

    $script:ManifestPath = $manifestFile.FullName
    $manifest = Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop
    $script:ModuleName = $manifest.Name

    Import-Module $script:ManifestPath -Force -ErrorAction Stop
}

AfterAll {
    if ($script:ModuleName) {
        Remove-Module $script:ModuleName -Force -ErrorAction SilentlyContinue
    }
}

Describe 'RobopackPS module' {

    Context 'Manifest' {
        It 'has a valid manifest' {
            { Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop } | Should -Not -Throw
        }

        It 'has a non-empty description' {
            $manifest = Test-ModuleManifest -Path $script:ManifestPath
            $manifest.Description | Should -Not -BeNullOrEmpty
        }

        It 'exports at least one function' {
            $manifest = Test-ModuleManifest -Path $script:ManifestPath
            $manifest.ExportedFunctions.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Module import' {
        It 'can be imported without errors' {
            { Get-Module $script:ModuleName } | Should -Not -Throw
        }

        It 'all exported functions are available after import' {
            $manifest  = Test-ModuleManifest -Path $script:ManifestPath
            $available = Get-Command -Module $script:ModuleName | Select-Object -ExpandProperty Name
            foreach ($fn in $manifest.ExportedFunctions.Keys) {
                $available | Should -Contain $fn
            }
        }
    }
}
