# Windows PowerShell. Set $Godot to your Godot 4.7.2 executable path.
param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Push-Location $Root
try {
    python tools/validate_project.py
    if ($LASTEXITCODE -ne 0) { throw "Static audit failed" }
    & $Godot --headless --path . --editor --import --quit
    if ($LASTEXITCODE -ne 0) { throw "Godot import failed" }
    & $Godot --headless --path . --script res://tests/test_runner.gd
    if ($LASTEXITCODE -ne 0) { throw "Godot regression tests failed" }
    Write-Host "Static + Godot tests PASS. Android device export/testing still required."
} finally {
    Pop-Location
}
