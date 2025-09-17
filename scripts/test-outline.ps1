param(
  [Parameter(Position = 0)]
  [string]$Topic = 'Flutter basico',
  [Parameter(Position = 1)]
  [string]$BaseUrl
)

if (-not $BaseUrl -or [string]::IsNullOrWhiteSpace($BaseUrl)) {
  $BaseUrl = $env:API_BASE_URL
  if (-not $BaseUrl -or [string]::IsNullOrWhiteSpace($BaseUrl)) {
    $BaseUrl = 'http://localhost:8787'
  }
}

$BaseUrl = $BaseUrl.TrimEnd('/')
$payload = @{ topic = $Topic } | ConvertTo-Json -Depth 3

Write-Host "POST $BaseUrl/outline" -ForegroundColor Cyan
Write-Host "topic: $Topic" -ForegroundColor DarkCyan

try {
  $response = Invoke-RestMethod -Method Post -Uri "$BaseUrl/outline" -Body $payload -ContentType 'application/json'
  $response | ConvertTo-Json -Depth 6
} catch {
  Write-Error $_
  if ($_.Exception.Response -and $_.Exception.Response.ContentLength -gt 0) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $detail = $reader.ReadToEnd()
    Write-Host "Error detail:" -ForegroundColor Yellow
    Write-Host $detail
  }
}
