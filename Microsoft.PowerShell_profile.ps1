
$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1
   
   
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
	Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons


$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

function Update-Powershell {
	if (-not $global:canConnectToGitHub) {
		Write-Host "Skipping PowerShell update check due to Github.com not responding within 1s." -ForgroundColor Cyan
		return
	}

	
	try {
		Write-Host "Checking for PowerShell updates..." -ForegroundColor Magenta
		$updateNeeded = $false
		$currentVersion = $PSVersionTable.PSVersion.ToString()
		$gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
		$latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
		$latestVersion = $latestReleaseInfo.tag_name.Trim('v')
		if ($currentVersion -lt $latestVersion) {
			$updateNeeded = $true
		}
		if ($updateNeeded) {
			Write-Host "Updating PowerShell..." -ForegroundColor Cyan
			winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
			
			Write-Host "PowerShell updated, Please restart your shell to reflect changes" -ForegroundColor Magenta
		} else {
		Write-Host "Up to date :)" -ForegroundColor Green
		} 
	} catch {
		Write-Error "Failed to update PowerShell :( Error: $_"
	}
}
	Update-PowerShell
		
		
function Test-CommandExists {
	param($command)
	$exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
	return $exists
}

$EDITOR = if (Test-CommandExists nvim) { 'nvim' }
		  elseif (Test-CommandExists pvim) { 'pvim' }
		  elseif (Test-CommandExists vim) { 'vim' }
		  elseif (Test-CommandExists vi) { 'vi' }
		  elseif (Test-CommandExists code) { 'code' }
		  elseif (Test-CommandExists notepad++) { 'notepad++' }
		  elseif (Test-CommandExists sublime_text) { 'sublime_text' }
		  else { 'notepad' }
Set-Alias -Name vim -Value $EDITOR

function edip {
	vim $PROFILE
	}

# gsudo like command, make sure you only use this to run requires admin priveleged scripts that you wrote or trust !
function Invoke-Sudo {
	param(
		[Parameter(Mandatory)]
		[string]$Command
	)

	$ScriptBlock = [ScriptBlock]::Create($Command)
	Start-Process Powershell -ArgumentList "-NoProfile", "-Command", $scriptBlock -Verb RunAs -WindowStyle hidden
}


function psudo {
	param(
	    [Parameter(Mandatory)]
	    [string]$Command
	)

	Invoke-Sudo -Command $Command
}

	# prompts you to choose directory to unzip file in, unzips it to the name of the *.zip file 
	# and prompts you if you want to cd into it, then deletes the .zip :) 
function unzip ($file) {
	
	$destination = Read-Host -Prompt "Enter the destination path for $file"
	$folderName = [System.IO.Path]::GetFileNameWithoutExtension($file)
	$destinationPath = Join-Path -Path $destination -ChildPath $folderName

	if (-not (Test-Path $destinationPath)) {
		New-Item -ItemType Directory -Path $destinationPath
	}
try {
	Expand-Archive -LiteralPath $file -DestinationPath $destinationPath -ErrorAction Stop
	Write-Host "Unzipped to $destinationPath"

	Remove-Item -Path $file -Force 
	Write-Host "$file has been removed and the newly unzipped folder has been created"

	$changeDir = Read-Host -Prompt "Do you want to cd into the directory of the unzipped folder? (Y/N)"

	if ($changeDir -eq 'Y') {
		Set-Location -Path $destinationPath
		Write-Host "Changed directory to $destinationPath"
	}
    } catch {
	    Write-Host "An error occured: $_"
    }
}

$PSROptions = @{
	ContinuationPrompt = ' '
	Colors			   = @{
	Parameter		   = $PSStyle.Foreground.Magenta
	Selection		   = $PSStyle.Background.Black
	InLinePrediction   = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack
	}
}
Set-PSReadLineOption @PSROptions
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine


		

function refresh {
	& $PROFILE
}

# something like which shell command in linux 

function whichsh {
	Write-Host $PSHome
}

function version {
"PowerShell Version {0}.{1}.{2}`n{4}" -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor, $PSVersionTable.PSVersion.Patch, $PSVersionTable.PSEdition, $PSVersionTable.os
}

function grep($regex, $dir) {
	if ( $dir ) {
		Get-ChildItem $dir | select-string $regex
		return
	}
	$input | Select-String $regex
}

function touch($file) { "" | Out-File $file -Encoding ASCII }

function ff($name) {
Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
	Write-Output "$($_.directory)\$($_)"
	}
}

# Format-list will provide more details, like df -h in Linux 
function df {
	Get-Volume | Format-List 
}

function sed($file, $find, $replace) {
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
	set-item -force -path "env:$name" -value $value;
}

function pgrep($name) {
	Get-Process $name
}

function pkill($name) {
	Get-Process $name -ErrorAction SilentlyContinue | Stop-Process 
}

function head {
	param($Path, $n = 10)
	Get-Content $Path -Head $n
}

function tail {
	param($Path, $n = 10)
	Get-Content $path -Tail $n 
}

# for notepad++ users
function npp {
	Start-Process "C:\Program Files\Notepad++\notepad++.exe"
}

# Git stuff

function g {
	z Github 
}

function gp { git push 
}

function gc { param($m) git commit -m "$m" }
function gs { git status 
}

function gcom {
	git add .
	git commit -m "$args"
}

function lazyg {
	git add .
	git commit -m "$args"
	git push
}
function gl {
	git log 
}

function gsh {
	git show
}
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

function mkz { param($dir) New-Item -ItemType $dir -Force; Set-Location $dir }

function dlod { Set-Location -Path $HOME\Downloads }

function roam { Set-Location -Path $HOME\AppData\Roaming }

function locald { Set-Location -Path $HOME\AppData\Local }

function li { Get-ChildItem | Format-Wide -Column 3 }
function ll { Get-ChildItem -Force | Sort-Object CreationTime -Descending | Format-Table  -Autosize Name, LastWriteTimeString, Attributes 
}
# Displays only the value of the IPv4 address of your chosen adapter
# ex: getip "Wifi" 	
function getip { 
	param(
		[Parameter(Mandatory=$true, Position=0)]
		[string]$AdapterName
	)
	
	$adapter = Get-NetAdapter | Where-Object { $_.Name -eq "$AdapterName" }
	
	if($adapter) {
		$adapter | Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
	} else {
		Write-Host "No adapter found for the name: $AdapterName`nTry Again" 
		}
}


# FileSize convert ex: 'filesize 10000000000' returns 9.31 GB 

function filesize {
	param([int64]$bytes)
	if ($bytes -gt 1GB) {
		"{0:N2} GB" -f ($bytes / 1GB)
	} elseif ($bytes -gt 1MB) {
		"{0:N2} MB" -f ($bytes / 1MB)
	} elseif ($bytes -gt 1KB) {
		"{0:N2} MB" -f ($bytes / 1KB)
	} else {
		"$bytes bytes"
	}

}
	

# Get Alias and functions from $PROFILE   !note! there is no description, just the alias ex: cpy 

function pal {
    $defaultCmdlets = Get-Command -CommandType Cmdlet | Select-Object -ExpandProperty Name
    $profileFunctions = Get-Content $PROFILE | Select-String 'function ' | ForEach-Object {
        [PSCustomObject]@{
            FunctionName = $_.ToString().Split(' ')[1]
            LineNumber = $_.LineNumber
        }
    }
    $customFunctions = $profileFunctions | Where-Object { $defaultCmdlets -notcontains $_.FunctionName }
    $customFunctions | Format-Table -AutoSize
}

# System 

function sysinfo { Get-ComputerInfo }

function flushdns { Clear-DnsClientCache }

function cpy { Set-Clipboard $args[0] }
function pst { Get-Clipboard }



oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight_storm.omp.json" | Invoke-Expression

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
	Invoke-Expression (& { (zoxide init powershell | Out-String) })
	} else {
		Write-Host: "zoxide command not found. Attempting to install via winget..."
		try {
			winget install -e --id ajeetdsouza.zoxide
			Write-Host "zoxide installed successfully, Initializing..."
			Invoke-Expression (& { (zoxide init powershell | Out-String) })
			} catch {
				Write-Error "Failed to install zoxide. Error: $_"
			}
}
