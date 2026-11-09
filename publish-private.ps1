$ErrorActionPreference = 'Stop'

$Repository = 'Linuchan5468/graylog-cisco-ios-pipeline'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed or is not available in PATH.'
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) is not installed or is not available in PATH.'
}

if (-not (Test-Path '.git')) {
    git init -b main
    if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
}

git add README.md rules samples publish-private.ps1
if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }

git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
    git commit -m 'Add Cisco IOS Graylog pipeline rules'
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
}
elseif ($LASTEXITCODE -ne 0) {
    throw 'Unable to inspect staged changes.'
}

gh repo create $Repository --private --source . --remote origin --push
if ($LASTEXITCODE -ne 0) { throw 'GitHub repository creation or push failed.' }

Write-Host "Published: https://github.com/$Repository"
