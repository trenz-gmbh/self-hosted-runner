Set-Location \actions-runner

& ./config.cmd --url $env:REG_URL --token $env:REG_TOKEN --name $env:NAME
& ./run.cmd
