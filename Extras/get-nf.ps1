try {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name

    $fonts = @("FiraMono", "GeistMono", "Hack", "Iosevka", "FiraCode", "AnonymousPro", "Cousine", "JetBrainsMono")

    for ($i=0; $i -lt $fonts.Length; $i++) {
        Write-Host "$($i+1): $($fonts[$i])"
    }

    $selection = Read-Host -Prompt "Enter The Number Of the font you would like to Download & Install"
    $font = $fonts[$selection - 1]
    Write-Host "You Chose: $font`n Now downloading $font"

    if ($fontFamilies -notcontains $font) {
        $webClient = New-Object System.Net.WebClient
       
        $webClient.DownloadFileAsync((New-Object System.Uri("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/$($font).zip")), ".\$($font).zip")

        while ($webClient.IsBusy) {
            Start-Sleep -Milliseconds 500
        }

       
        Expand-Archive -Path ".\$($font).zip" -DestinationPath ".\$($font)" -Force
        $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
        Get-ChildItem -Path ".\$($font)" -Recurse -Filter "*.ttf" | ForEach-Object {
            If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                $destination.CopyHere($_.FullName, 0x10)
            }
        }

        Remove-Item -Path ".\$($font)" -Recurse -Force
        Remove-Item -Path ".\$($font).zip" -Force
    }
} catch {
	Write-Error "An Error happened: $_"
}
