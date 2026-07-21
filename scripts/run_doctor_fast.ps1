param(
  [ValidateSet("edge", "chrome", "web-server")]
  [string]$Device = "edge",
  [int]$Port = 7357
)

$ErrorActionPreference = "Stop"
$env:NO_PROXY = "localhost,127.0.0.1"
$env:no_proxy = "localhost,127.0.0.1"

$Flutter = "D:\Flutter\flutter\bin\flutter.bat"
if (-not (Test-Path $Flutter)) {
  $Flutter = "flutter"
}

& $Flutter run -d $Device -t lib/main_doctor.dart --web-hostname 127.0.0.1 --web-port $Port
