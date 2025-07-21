Set-Location C:\actions-runner

if (-not $env:REG_URL -or -not $env:REG_TOKEN -or -not $env:NAME) {
	Write-Error "Missing required environment variables:`n`tREG_URL=$env:REG_URL`n`tREG_TOKEN=$env:REG_TOKEN`n`tNAME=$env:NAME"
	exit 1
}

Write-Host "Environment validated:"
Write-Host "`tREG_URL: $env:REG_URL"
Write-Host "`tNAME:    $env:NAME"

# Register the runner
Write-Host "Configuring the GitHub Actions runner..."
& .\config.cmd --url $env:REG_URL --token $env:REG_TOKEN --name $env:NAME --unattended

if ($LASTEXITCODE -ne 0) {
	Write-Error "Runner configuration failed with exit code $LASTEXITCODE"
	exit $LASTEXITCODE
}

# Define cleanup logic
$cleanup = {
	Write-Host "`nStopping runner, removing config..."
	& .\config.cmd remove --unattended --token $env:REG_TOKEN

	if ($LASTEXITCODE -ne 0) {
		Write-Warning "Runner removal failed with exit code $LASTEXITCODE"
		exit $LASTEXITCODE
	}

	exit 0
}

# Handle termination signals (Ctrl+C and TERM)
# Ctrl+C (SIGINT) handling
Register-EngineEvent PowerShell.Exiting -Action $cleanup | Out-Null


# Start the runner in background
Write-Host "Starting the GitHub Actions runner..."
Start-Process -FilePath ".\run.cmd" -NoNewWindow -Wait
