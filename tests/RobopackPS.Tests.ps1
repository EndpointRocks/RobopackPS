BeforeAll {
    $manifestPath = Join-Path $PSScriptRoot '..\RobopackPS\RobopackPS.psd1'
    Import-Module $manifestPath -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module RobopackPS -Force -ErrorAction SilentlyContinue
}

Describe 'RobopackPS module' {

    Context 'Manifest' {
        It 'has a valid manifest' {
            $manifestPath = Join-Path $PSScriptRoot '..\RobopackPS\RobopackPS.psd1'
            { Test-ModuleManifest -Path $manifestPath -ErrorAction Stop } | Should -Not -Throw
        }

        It 'has a non-empty description' {
            $manifest = Test-ModuleManifest -Path (Join-Path $PSScriptRoot '..\RobopackPS\RobopackPS.psd1')
            $manifest.Description | Should -Not -BeNullOrEmpty
        }

        It 'exports at least one function' {
            $manifest = Test-ModuleManifest -Path (Join-Path $PSScriptRoot '..\RobopackPS\RobopackPS.psd1')
            $manifest.ExportedFunctions.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Module import' {
        It 'can be imported without errors' {
            { Get-Module RobopackPS } | Should -Not -Throw
        }

        It 'all exported functions are available after import' {
            $manifest  = Test-ModuleManifest -Path (Join-Path $PSScriptRoot '..\RobopackPS\RobopackPS.psd1')
            $available = Get-Command -Module RobopackPS | Select-Object -ExpandProperty Name
            foreach ($fn in $manifest.ExportedFunctions.Keys) {
                $available | Should -Contain $fn
            }
        }
    }
}
